import 'package:aasyou/config/helper.dart';

/// Represents the home-section visibility toggles delivered by
/// `GET /api/settings/web` -> `data.value`.
///
/// All flags are nullable. Per backend contract: every flag defaults to
/// `true` server-side, and a missing / null value should also be treated
/// as `true`. Use [isEnabled] for the canonical lookup.
class WebSettings {
  WebSettings({
    this.homeTopRatedSection,
    this.homeFeaturedProductsSection,
    this.homeFeaturedSection,
    this.homeShopByCategorySection,
    this.homeFeaturedBrandsSection,
  });

  /// Canonical flag keys (mirror the backend camelCase keys).
  static const String kHomeTopRatedSection = 'homeTopRatedSection';
  static const String kHomeFeaturedProductsSection =
      'homeFeaturedProductsSection';
  static const String kHomeFeaturedSection = 'homeFeaturedSection';
  static const String kHomeShopByCategorySection = 'homeShopByCategorySection';
  static const String kHomeFeaturedBrandsSection = 'homeFeaturedBrandsSection';

  final bool? homeTopRatedSection;
  final bool? homeFeaturedProductsSection;
  final bool? homeFeaturedSection;
  final bool? homeShopByCategorySection;
  final bool? homeFeaturedBrandsSection;

  /// Builds a [WebSettings] from the `data.value` payload. Missing keys
  /// resolve to `null` (and therefore `true` via [isEnabled]).
  factory WebSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WebSettings();
    return WebSettings(
      homeTopRatedSection: parseBool(json[kHomeTopRatedSection]),
      homeFeaturedProductsSection:
          parseBool(json[kHomeFeaturedProductsSection]),
      homeFeaturedSection: parseBool(json[kHomeFeaturedSection]),
      homeShopByCategorySection: parseBool(json[kHomeShopByCategorySection]),
      homeFeaturedBrandsSection: parseBool(json[kHomeFeaturedBrandsSection]),
    );
  }

  /// Returns the visibility flag for [key]. Unknown keys and `null` values
  /// are treated as enabled (default = true).
  bool isEnabled(String key) {
    switch (key) {
      case kHomeTopRatedSection:
        return homeTopRatedSection ?? true;
      case kHomeFeaturedProductsSection:
        return homeFeaturedProductsSection ?? true;
      case kHomeFeaturedSection:
        return homeFeaturedSection ?? true;
      case kHomeShopByCategorySection:
        return homeShopByCategorySection ?? true;
      case kHomeFeaturedBrandsSection:
        return homeFeaturedBrandsSection ?? true;
      default:
        return true;
    }
  }
}
