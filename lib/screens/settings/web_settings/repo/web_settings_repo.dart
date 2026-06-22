import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/screens/settings/web_settings/model/web_settings_model.dart';

class WebSettingsRepository {
  /// Fetches the home-section visibility toggles from
  /// `GET /api/settings/web`.
  ///
  /// The backend returns the camelCase boolean flags inside `data.value`.
  /// Missing keys fall back to `null`, which [WebSettings.isEnabled] then
  /// resolves to `true`.
  Future<WebSettings> fetchWebSettings() async {
    try {
      final response = await AppHelpers.apiBaseHelper.getAPICall(
        '${ApiRoutes.settingsApi}/web',
        {},
      );

      final data = response.data;
      if (data is! Map) return WebSettings();

      final dataNode = data['data'];
      if (dataNode is! Map) return WebSettings();

      final rawValue = dataNode['value'];
      Map<String, dynamic>? valueMap;
      if (rawValue is Map) {
        valueMap = Map<String, dynamic>.from(rawValue);
      }

      return WebSettings.fromJson(valueMap);
    } catch (_) {
      // Phase A foundation: never block UI on a settings fetch failure.
      // Fall back to defaults (every flag enabled).
      throw ApiException('Failed to fetch web settings');
    }
  }
}
