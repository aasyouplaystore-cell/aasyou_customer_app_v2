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
      String? productSlug = _extractProductSlug(uri);

      if (productSlug != null && productSlug.isNotEmpty) {
        log('Redirecting to product detail page with slug: $productSlug');

        // Ensure we're on the main thread and context is still valid
        await WidgetsBinding.instance.endOfFrame;
        if (!navigatorContext.mounted) return;

        final router = GoRouter.of(navigatorContext);
        
        // Ensure Home is the base route
        router.go(AppRoutes.home);
        
        // Navigate to product detail page on top of Home
        router.push(
          AppRoutes.productDetailPage,
          extra: {'productSlug': productSlug},
        );
        _hasPendingLink = false; // Successfully handled
      } else {
        log('No product slug found in deep link: $uri');
        _hasPendingLink = false;
      }
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

  String? _extractProductSlug(Uri uri) {
    if (uri.pathSegments.contains('product') ||
        uri.pathSegments.contains('p')) {
      final index = uri.pathSegments.contains('product')
          ? uri.pathSegments.indexOf('product')
          : uri.pathSegments.indexOf('p');

      if (index != -1 && index + 1 < uri.pathSegments.length) {
        final slug = uri.pathSegments[index + 1];
        if (slug.isNotEmpty) return slug;
      }
    }

    // 2. Check query parameters (e.g., ?slug=my-slug or ?product_slug=my-slug)
    if (uri.queryParameters.containsKey('slug')) {
      return uri.queryParameters['slug'];
    }
    if (uri.queryParameters.containsKey('product_slug')) {
      return uri.queryParameters['product_slug'];
    }

    // 3.
    const keywords = {'product', 'p', 'home', 'shop', 'categories', 'cart'};
    const nonProductPathKeys = {'r', 'referral', 'invite'};
    if (uri.pathSegments.isNotEmpty) {
      // Skip if any segment indicates a non-product link (e.g. referral).
      final segmentSet =
          uri.pathSegments.map((s) => s.toLowerCase()).toSet();
      if (segmentSet.any(nonProductPathKeys.contains)) {
        return null;
      }
      final lastSegment = uri.pathSegments.last;
      if (lastSegment.isNotEmpty &&
          !keywords.contains(lastSegment.toLowerCase())) {
        return lastSegment;
      }
    }

    return null;
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
