import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:aasyou/config/api_routes.dart';
import 'package:aasyou/config/helper.dart';
import '../model/app_version_model.dart';
import '../model/update_config.dart';

class AppVersionRepository {
  Future<UpdateConfig> fetchUpdateConfig() async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        '${ApiRoutes.versionCheckApi}?platform=$platform',
        {
          'current_version': AppHelpers.systemVersion,
          'app': 'customer'
        },
      );

      if (response.statusCode != 200) {
        log('[AppVersionRepo] API returned ${response.statusCode} — failing open');
        return _upToDate();
      }

      final Map<String, dynamic> jsonResponse;

      if (response.data is String) {
        jsonResponse = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        jsonResponse = response.data as Map<String, dynamic>;
      }

      // Use the model you already have (Recommended)
      final apiResponse = AppVersionModel.fromJson(jsonResponse);

      final model = apiResponse.data;
      if (model != null) {
        log('[AppVersionRepo] API Response -> '
            'update_available: ${model.updateAvailable}, '
            'update_type: ${model.updateType}, '
            'min_supported: ${model.minSupportedVersion}, '
            'latest: ${model.latestVersion}, '
            'message: ${model.message}');

        if (model.updateAvailable == true) {
          final isForce = model.updateType == 'force' ||
              model.updateType == 'force_update';
          log('[AppVersionRepo] Update type: ${model.updateType}, isForce: $isForce');
          return UpdateConfig(
            status: isForce ? UpdateStatus.forceUpdate : UpdateStatus.optionalUpdate,
            title: isForce ? 'Update Required' : 'Update Available',
            message: model.message?.isNotEmpty == true
                ? model.message!
                : isForce
                    ? 'Please update the app to continue using our services.'
                    : 'A new version is available. Would you like to update?',
            iosStoreUrl: model.updateUrl ?? '',
            androidStoreUrl: model.updateUrl ?? '',
            updateAvailable: true,
            updateType: model.updateType ?? '',
            minSupportedVersion: model.minSupportedVersion ?? '',
            latestVersion: model.latestVersion,
          );
        }
      }
      return _upToDate();
    } catch (e, stack) {
      log('[AppVersionRepo] Error fetching update config: $e', error: e, stackTrace: stack);
      return _upToDate();
    }
  }

  static UpdateConfig _upToDate() => const UpdateConfig(
    status: UpdateStatus.upToDate,
    title: '',
    message: '',
    iosStoreUrl: '',
    androidStoreUrl: '',
  );
}