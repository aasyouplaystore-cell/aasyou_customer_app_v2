import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/bloc/device_sync_bloc/device_sync_bloc.dart';
import 'package:aasyou/bloc/settings_bloc/settings_bloc.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/home_page/bloc/brands/brands_bloc.dart';
import 'package:aasyou/screens/user_profile/bloc/user_profile_bloc/user_profile_bloc.dart';
// custom_image_container removed — splash now renders a single asset image.
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bloc/user_details_bloc/user_details_bloc.dart';
import '../../bloc/user_details_bloc/user_details_state.dart';
import '../../config/global.dart';
import '../../config/helper.dart';
import '../../config/settings_data_instance.dart';
import '../../config/theme.dart';
import '../../services/location/location_service.dart';
import '../../utils/app_update/bloc/app_update_bloc.dart';
import '../../utils/app_update/bloc/app_update_event.dart';
import '../../utils/app_update/bloc/app_update_state.dart';
import '../../utils/app_update/model/update_config.dart';
import '../../utils/app_update/widgets/app_update_dialog.dart';
import '../home_page/bloc/banner/banner_bloc.dart';
import '../home_page/bloc/banner/banner_event.dart';
import '../home_page/bloc/category/category_bloc.dart';
import '../home_page/bloc/category/category_event.dart';
import '../home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import '../home_page/bloc/feature_section_product/feature_section_product_event.dart';
import '../home_page/bloc/sub_category/sub_category_bloc.dart';
import '../home_page/bloc/sub_category/sub_category_event.dart';
import '../../deep_link.dart';
import 'package:aasyou/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {

  bool _hasInitialized        = false;
  bool _hasNavigated          = false;
  bool _lastKnownConnectivity = false;
  bool _settingsRequested     = false;
  bool _updateGateResolved    = false;
  bool _updateDialogShowing   = false;
  Timer? _splashTimeoutTimer;

  // Hard ceiling on splash time. After this we force-navigate to home
  // regardless of in-flight gates (update check, settings fetch,
  // location resolve). The actual happy-path splash is ~1s; this
  // ceiling only kicks in if a network call wedges.
  static const Duration _splashTimeout = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Kick off version check — runs in parallel with the splash render.
    // We DO NOT block navigation on this anymore: if AppUpdateBloc
    // never emits a state (slow API / dead host), the timeout below
    // navigates the user to home from cached state anyway.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppUpdateBloc>().add(CheckAppUpdate());
    });
    // Hard ceiling. Previously the splash was gated on AppUpdate +
    // SettingsLoaded + connectivity + location + a hardcoded 1s pause,
    // any of which could hang indefinitely. Cap the total wait so the
    // user is never stuck on the splash on a slow network.
    _splashTimeoutTimer = Timer(_splashTimeout, _forceNavigateIfStuck);
  }

  /// Hard-ceiling escape hatch. Fires after [_splashTimeout]. Forces
  /// the user past the splash to the home screen regardless of which
  /// gate is still in flight. SettingsBloc / AppUpdateBloc / location
  /// continue running in the background and the home screen consumes
  /// their state when it emits.
  void _forceNavigateIfStuck() {
    if (!mounted || _hasNavigated) return;
    log('Splash: timeout ceiling reached; forcing navigate to home.');
    _resolveGate();
    // Even if connectivity / settings haven't arrived, push the user
    // to home — the empty-state UI handles missing settings gracefully.
    _hasNavigated = true;
    Global.setIsFirstTime(false);
    if (AppLinksDeepLink.instance.hasPendingLink) return;
    GoRouter.of(context).go(AppRoutes.home);
  }

  @override
  void dispose() {
    _splashTimeoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── Update gate ───────────────────────────────────────────────────────────

  void _resolveGate() {
    if (_updateGateResolved) return;
    _updateGateResolved = true;
    _startSettingsIfReady();
  }


  /// Called when a soft-update dialog is dismissed via "Do it later".
  void _onSoftUpdateLater() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    _updateDialogShowing = false;
    _resolveGate();
  }

  // ── AppUpdate dialog ──────────────────────────────────────────────────────
  void _showUpdateDialog(UpdateConfig config, {required bool isForced}) {
    if (_updateDialogShowing || !mounted) return;
    _updateDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppUpdateDialog(
        config: config,
        isForced: isForced,
        onLater: _onSoftUpdateLater,
      ),
    );
  }

  // ── Settings & navigation gate ────────────────────────────────────────────
  void _requestSettingsFetch() {
    if (!mounted || _settingsRequested) return;
    _settingsRequested = true;
    context.read<SettingsBloc>().add(FetchSettingsData(context: context));
  }

  void _startSettingsIfReady() {
    if (!_updateGateResolved || !_lastKnownConnectivity) return;
    _requestSettingsFetch();
  }

  // ── Location helpers ──────────────────────────────────────────────────────

  Future<bool?> _showLocationAccessDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(dialogContext)!.locationAccessNeeded),
        content: Text(
          AppLocalizations.of(dialogContext)!.locationAccessDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(dialogContext)!.later),
          ),
          TextButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();
              if (dialogContext.mounted) Navigator.pop(dialogContext, true);
            },
            child: Text(AppLocalizations.of(dialogContext)!.openSettings),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              if (dialogContext.mounted) Navigator.pop(dialogContext, true);
            },
            child: Text(AppLocalizations.of(dialogContext)!.appPermissions),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAndSetLocation() async {
    // Already have a stored location → reuse it (Hive persists across runs).
    if (!AppHelpers.isDemo && LocationService.hasStoredLocation()) return;

    // Demo build → pin to the demo lat/lng so the UI is deterministic.
    if (AppHelpers.isDemo) {
      final demoLat = AppHelpers.defaultLat;
      final demoLng = AppHelpers.defaultLng;
      if (demoLat.isNotEmpty && demoLng.isNotEmpty) {
        await LocationService.storeLocationFromCoordinates(
          latitude: demoLat,
          longitude: demoLng,
        );
        return;
      }
    }

    // Zepto/Blinkit-style: try to silently resolve the device's current GPS
    // location FIRST. If permission is already granted this is one
    // background call and the user never sees a picker. If permission isn't
    // granted yet, the OS prompt fires exactly once; on subsequent launches
    // the stored location is reused (see early-return above).
    final auto = await LocationService.tryAutoLocateSilent();
    if (auto != null) return;

    // GPS unavailable / denied → fall back to the admin's default lat/lng
    // so the home page still has SOMETHING to render. The user can switch
    // location manually from the header chip at any time.
    final webSettings = SettingsData.instance.web;
    final lat = webSettings?.defaultLatitude;
    final lng = webSettings?.defaultLongitude;
    if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
      await LocationService.storeLocationFromCoordinates(
        latitude: lat,
        longitude: lng,
      );
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> navigate() async {
    _dispatchInitialDataFetches();
    _syncDeviceIfLoggedIn();
    if (_hasNavigated) return;
    _hasNavigated = true;
    _splashTimeoutTimer?.cancel();

    if (!mounted) {
      _hasNavigated = false;
      return;
    }

    // Onboarding/intro slides removed (parity with the Zepto / Blinkit
    // "no walkthrough" flow). Cold start now goes splash → home directly,
    // shaving ~3 frames of first-launch lag and removing the chance of
    // out-of-zone users seeing the intro before the home empty state.
    Global.setIsFirstTime(false);

    if (AppLinksDeepLink.instance.hasPendingLink) {
      log('Deep link pending, skipping splash screen navigation');
      return;
    }

    GoRouter.of(context).go(AppRoutes.home);
  }

  void _handleConnectivityChanged(bool isConnected) {
    _lastKnownConnectivity = isConnected;

    if (!isConnected) {
      _hasNavigated = false;
      return;
    }

    if (!_hasInitialized) {
      _hasInitialized = true;
      if (_updateGateResolved) navigate();
      return;
    }

    if (!_hasNavigated && _updateGateResolved) navigate();
  }

  void _dispatchInitialDataFetches() {
    context.read<CategoryBloc>().add(FetchCategory(context: context));
    context.read<BannerBloc>().add(FetchBanner(categorySlug: ""));
    context.read<BrandsBloc>().add(const FetchBrands(categorySlug: ""));
    context.read<SubCategoryBloc>()
        .add(FetchSubCategory(slug: "", isForAllCategory: true));
    context
        .read<FeatureSectionProductBloc>()
        .add(FetchFeatureSectionProducts(slug: ""));
    context.read<UserProfileBloc>().add(FetchUserProfile());
  }

  void _syncDeviceIfLoggedIn() {
    if (Global.userData != null && Global.userData!.token.isNotEmpty) {
      context.read<DeviceSyncBloc>().add(SyncDevice(
        deviceType: Platform.isAndroid ? 'android' : 'ios',
        previousToken: Global.userData?.fcm ?? '',
        roleType: 'customer',
      ));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppUpdateBloc, AppUpdateState>(
      listener: (context, state) {
        if (state is AppUpdateConfigLoaded) {
          if (!state.isUpdateAvailable) {
            _resolveGate();
          } else {
            final isForced = state.isForced;
            _showUpdateDialog(state.config, isForced: isForced);
          }
        }
        if (state is AppUpdateFailed) {
          _resolveGate();
        }
      },
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) async {
          if (state is MaintenanceModeEnabled) {
            GoRouter.of(context).go(
              AppRoutes.maintenancePage,
              extra: {'message': state.maintenanceModeMessage},
            );
            return;
          }
          if (state is SettingsLoaded) {
            if (SettingsData.instance.system!.webMaintenanceMode!) {
              GoRouter.of(context).go(AppRoutes.maintenancePage);
              return;
            }
            // Fire-and-forget location resolve — it was previously
            // awaited here, but Geolocator.tryAutoLocateSilent can
            // take 5+ seconds on a fresh install with weak GPS. Home
            // page's location chip handles the "no location yet"
            // state gracefully (defaults to admin's lat/lng or
            // prompts the user) so there's no UX cost to deferring.
            unawaited(_checkAndSetLocation().catchError((e) {
              log('Splash: background location resolve failed: $e');
            }));
            // Navigate immediately — don't wait for connectivity event
            // either. If the device is offline, home renders the
            // no-internet banner; if it's online, the BLoCs we
            // dispatched fill in data as they arrive.
            if (!_hasNavigated) navigate();
          }
        },
        child: BlocListener<UserDataBloc, UserDataState>(
          listener: (context, state) {},
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScaffold(
      showViewCart: false,
      notifyConnectivityStatusOnInit: true,
      onConnectivityChanged: (isConnected, _) {
        _lastKnownConnectivity = isConnected;
        if (!_updateGateResolved) {
          if (isConnected) _startSettingsIfReady();
          return;
        }
        if (context.read<SettingsBloc>().state is SettingsLoaded) {
          _handleConnectivityChanged(isConnected);
        } else if (isConnected) {
          _startSettingsIfReady();
        }
      },
      // AasYou 2.0 splash: composable, brand-orange canvas with the white
      // wordmark logo and a slim progress dot. Replaces the 1.3MB
      // Aasyou-0.png so cold start stays under ~300ms.
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.primaryColor,
        child: SafeArea(
          child: Stack(
            children: [
              // Subtle radial highlight behind the logo — pure widget paint,
              // no image asset needed.
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.7,
                      colors: [
                        Color(0x33FFFFFF),
                        Color(0x00FFFFFF),
                      ],
                    ),
                  ),
                ),
              ),
              // Logo + wordmark. The source asset paints in brand-orange,
              // so we mask it to pure white with a ColorFilter so it pops
              // on the orange splash canvas.
              Center(
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/logo_with_name_white.png',
                    width: 200,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'AasYou',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom progress indicator.
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
