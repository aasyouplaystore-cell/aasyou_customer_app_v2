import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/services/referral_attribution_service.dart';
import 'config/global_keys.dart';

class AppLinksDeepLink {
  AppLinksDeepLink._privateConstructor();

  static final AppLinksDeepLink _instance =
      AppLinksDeepLink._privateConstructor();
  static AppLinksDeepLink get instance => _instance;

  late final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _isInitialized = false;
  Uri? _lastProcessedUri;
  bool _hasPendingLink = false;

  bool get hasPendingLink => _hasPendingLink;

  void clearPendingLink() {
    _hasPendingLink = false;
  }

  Future<void> initDeepLinks(BuildContext context) async {
    if (_isInitialized) {
      log('Deep links already initialized, skipping');
      return;
    }
    _isInitialized = true;

    try {
      log('NAVIGATOR CONTEXT INITIALIZED');

      // Handle initial link if the app was opened via a link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        log('Initial deep link: $initialUri');
        _hasPendingLink = true;
        if (context.mounted) {
          await _handleDeepLink(initialUri, context);
        }
      }

      // Listen for subsequent links while the app is running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri? uri) async {
          log('Received deep link: $uri');
          if (uri != null) {
            _hasPendingLink = true;
            if (context.mounted) {
              await _handleDeepLink(uri, context);
            }
          }
        },
        onError: (err) {
          log('Deep link error: $err');
        },
      );
    } catch (e, stack) {
      log('Deep link initialization error: $e');
      log('Stack trace: $stack');
    }
  }

  Future<void> _handleDeepLink(Uri uri, BuildContext context) async {
    if (_isFirebaseAuthCallback(uri)) {
      log('Ignoring Firebase Auth callback deep link: ${uri.scheme}://${uri.host}${uri.path}');
      _hasPendingLink = false;
      return;
    }

    if (_lastProcessedUri == uri) {
      log('URI $uri was just processed, skipping');
      return;
    }
    _lastProcessedUri = uri;
    _hasPendingLink = true;

    // Clear the last processed URI after a short delay to allow re-processing the same link later
    Future.delayed(const Duration(seconds: 2), () {
      if (_lastProcessedUri == uri) {
        _lastProcessedUri = null;
      }
    });

    final navigatorContext = GlobalKeys.navigatorKey.currentContext;
    if (navigatorContext == null) {
      log('Navigator context is null, skipping deep link handling');
      return;
    }


    // Capture any referral code into local storage so it can be auto-applied
    // after the user completes social sign-in. This runs alongside (not
    // instead of) the product-slug routing below.
    final String? referralCode = _extractReferralCode(uri);
    if (referralCode != null && referralCode.isNotEmpty) {
      try {
        await GetIt.instance<ReferralAttributionService>().setCode(referralCode);
        log('Captured referral code from deep link: $referralCode');
      } catch (e) {
        log('Failed to persist referral code: $e');
      }
    }

    try {
      // Store is resolved BEFORE product: a /stores/{slug} link must never be
      // mistaken for a product (the old last-segment fallback did exactly that).
      final String? storeSlug = _extractStoreSlug(uri);
      final String? productSlug = _extractProductSlug(uri);

      await WidgetsBinding.instance.endOfFrame;
      if (!navigatorContext.mounted) return;

      final router = GoRouter.of(navigatorContext);
      // Home is always the base route so Back from the deep-linked page lands
      // somewhere sane.
      router.go(AppRoutes.home);

      if (storeSlug != null && storeSlug.isNotEmpty) {
        log('Deep link -> store detail: $storeSlug');
        router.push(
          AppRoutes.nearbyStoreDetails,
          extra: {'store-slug': storeSlug, 'store-name': ''},
        );
      } else if (productSlug != null && productSlug.isNotEmpty) {
        log('Deep link -> product detail: $productSlug');
        router.push(
          AppRoutes.productDetailPage,
          extra: {'productSlug': productSlug},
        );
      } else {
        // Unknown / unsupported link — land on Home instead of dropping the
        // link (or, once https App Links are live, crashing to "Page Not Found").
        log('Deep link had no product/store target, staying on Home: $uri');
      }
      _hasPendingLink = false;
    } catch (e, stack) {
      _hasPendingLink = false;
      debugPrint('Navigation error: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  /// Returns true when the URI is a Firebase Auth callback that the Firebase.
  bool _isFirebaseAuthCallback(Uri uri) {
    // Google's reverse-client-ID scheme is used for OAuth + Firebase callbacks.
    if (uri.scheme.startsWith('com.googleusercontent.apps.')) return true;

    // Custom `<bundle>://firebaseauth/...` or `<scheme>://firebase-auth/...`
    final host = uri.host.toLowerCase();
    if (host == 'firebaseauth' || host == 'firebase-auth') return true;

    // Firebase Auth callback query params (any of these means Firebase owns it).
    if (uri.queryParameters.containsKey('deep_link_id')) return true;
    if (uri.queryParameters.containsKey('authType')) return true;

    // Email-link sign-in and reCAPTCHA callbacks on the Firebase hosting domain.
    if (uri.path.contains('/__/auth/')) return true;

    return false;
  }

  /// Extracts a referral code from an invite-style deep link.
  /// Supports path forms like `/r/CODE`, `/referral/CODE`, `/invite/CODE`
  /// and query params `?ref=CODE` / `?referral_code=CODE` / `?friends_code=CODE`.
  String? _extractReferralCode(Uri uri) {
    const pathKeys = {'r', 'referral', 'invite'};
    for (final key in pathKeys) {
      if (uri.pathSegments.contains(key)) {
        final idx = uri.pathSegments.indexOf(key);
        if (idx != -1 && idx + 1 < uri.pathSegments.length) {
          final code = uri.pathSegments[idx + 1].trim();
          if (code.isNotEmpty) return code;
        }
      }
    }

    const queryKeys = ['ref', 'referral_code', 'friends_code', 'invite_code'];
    for (final key in queryKeys) {
      final value = uri.queryParameters[key]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }

    return null;
  }

  /// Path segments with surrounding whitespace and empty entries removed.
  /// The empty-entry filter is what makes trailing-slash URLs work: the web
  /// serves canonical `/products/{slug}/` (trailingSlash:true), whose last
  /// path segment is an empty string — the old parser saw that empty string
  /// and dropped the link.
  List<String> _cleanSegments(Uri uri) =>
      uri.pathSegments.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  /// The segment immediately after the first segment matching any [keys].
  String? _segmentAfter(List<String> segments, Set<String> keys) {
    for (var i = 0; i < segments.length; i++) {
      if (keys.contains(segments[i].toLowerCase()) && i + 1 < segments.length) {
        final s = segments[i + 1].trim();
        if (s.isNotEmpty) return s;
      }
    }
    return null;
  }

  /// Product slug from:
  ///   /products/{slug}  ·  /share/products/{slug}  ·  /product/{slug}  ·  /p/{slug}
  ///   aasyou://products?slug=…  ·  ?slug=… / ?product_slug=…
  /// Returns null for store links so they can never be misrouted to a product
  /// (the old last-segment fallback treated /stores/{slug} as a product).
  String? _extractProductSlug(Uri uri) {
    final segments = _cleanSegments(uri);
    final host = uri.host.toLowerCase();
    final lower = segments.map((s) => s.toLowerCase());

    // A store URL is never a product.
    if (host == 'stores' || host == 'store' ||
        lower.contains('stores') || lower.contains('store')) {
      return null;
    }

    final afterKeyword =
        _segmentAfter(segments, const {'products', 'product', 'p'});
    if (afterKeyword != null) return afterKeyword;

    // Custom-scheme host form: aasyou://products?slug=X
    if (host == 'products' || host == 'product' || host == 'p') {
      final q = uri.queryParameters['slug']?.trim() ??
          uri.queryParameters['product_slug']?.trim();
      if (q != null && q.isNotEmpty) return q;
    }

    final slug = uri.queryParameters['slug']?.trim() ??
        uri.queryParameters['product_slug']?.trim();
    if (slug != null && slug.isNotEmpty) return slug;

    return null;
  }

  /// Store slug from:
  ///   /stores/{slug}  ·  /store/{slug}  ·  aasyou://stores?slug=…  ·  ?store_slug=…
  String? _extractStoreSlug(Uri uri) {
    final segments = _cleanSegments(uri);
    final host = uri.host.toLowerCase();

    final afterKeyword = _segmentAfter(segments, const {'stores', 'store'});
    if (afterKeyword != null) return afterKeyword;

    if (host == 'stores' || host == 'store') {
      final q = uri.queryParameters['slug']?.trim() ??
          uri.queryParameters['store_slug']?.trim() ??
          uri.queryParameters['store-slug']?.trim();
      if (q != null && q.isNotEmpty) return q;
    }

    return null;
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
