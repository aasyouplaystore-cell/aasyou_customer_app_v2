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
import 'package:aasyou/utils/widgets/custom_image_container.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Kick off version check — navigation is blocked until this resolves
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppUpdateBloc>().add(CheckAppUpdate());
    });
  }

  @override
  void dispose() {
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
    if (!AppHelpers.isDemo && LocationService.hasStoredLocation()) return;

    String? lat, lng;
    final webSettings = SettingsData.instance.web;
    if (webSettings != null) {
      lat = webSettings.defaultLatitude;
      lng = webSettings.defaultLongitude;
    }

    if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
      await LocationService.storeLocationFromCoordinates(
        latitude: lat,
        longitude: lng,
      );
      return;
    }

    if (AppHelpers.isDemo) {
      lat = AppHelpers.defaultLat;
      lng = AppHelpers.defaultLng;
      if (lat.isNotEmpty && lng.isNotEmpty) {
        await LocationService.storeLocationFromCoordinates(
          latitude: lat,
          longitude: lng,
        );
        return;
      }
    }

    if (!LocationService.hasStoredLocation()) {
      final bool? granted = await _showLocationAccessDialog();
      if (granted == true) {
        await LocationService.requestAndStoreLocationWithRetry();
      }
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> navigate() async {
    _dispatchInitialDataFetches();
    _syncDeviceIfLoggedIn();
    if (_hasNavigated) return;
    _hasNavigated = true;
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted || !_lastKnownConnectivity) {
      _hasNavigated = false;
      return;
    }

    if (Global.isFirstTime) {
      GoRouter.of(context).go(AppRoutes.introSlider);
      return;
    }

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
            await _checkAndSetLocation();
            if (_lastKnownConnectivity) _handleConnectivityChanged(true);
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
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              image: DecorationImage(
                image: AssetImage('assets/images/doodle.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: CustomImageContainer(
                  imagePath: getAppLogoUrl(context),
                  height: 180,
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
