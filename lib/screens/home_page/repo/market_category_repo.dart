import 'dart:convert';
import 'dart:developer';

import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';

import '../../../config/helper.dart';
import '../../../services/location/location_service.dart';

/// Repository for market-categories endpoints.
///
/// Mirrors [CategoryRepository] - returns raw `Map<String, dynamic>`
/// payloads so the bloc layer keeps using `response['data']['data']`
/// access patterns. Throws [ApiException] on list/detail failures.
/// Stores method swallows errors and returns null to match the existing
/// nearby-stores degrade-gracefully behaviour.
class MarketCategoryRepository {
  /// GET /market-categories — list/search/filter/paginate.
  ///
  /// When [slug] is provided the backend returns both `data` (children)
  /// and `main_category_data` (the parent market itself).
  Future<Map<String, dynamic>> fetchMarketCategories({
    required int perPage,
    required int currentPage,
    String? slug,
    bool includeNoProduct = true,
  }) async {
    try {
      final stored = LocationService.getStoredLocation();
      final latitude = stored?.latitude;
      final longitude = stored?.longitude;

      final Map<String, dynamic> query = {
        'per_page': perPage.toString(),
        'page': currentPage.toString(),
        'include_no_product': includeNoProduct.toString(),
        if (slug != null && slug.isNotEmpty) 'slug': slug,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        ApiRoutes.marketCategoryApi,
        query,
      );
      return _asMap(response.data);
    } catch (e) {
      throw ApiException('Failed to fetch market categories');
    }
  }

  /// Convenience wrapper: detail mode (always passes slug + include_no_product).
  Future<Map<String, dynamic>> fetchMarketCategoryDetail({
    required String slug,
    int perPage = 30,
    int currentPage = 1,
  }) {
    return fetchMarketCategories(
      perPage: perPage,
      currentPage: currentPage,
      slug: slug,
      includeNoProduct: true,
    );
  }

  /// GET /market-categories/sidebar — flat filter list.
  Future<Map<String, dynamic>> fetchMarketCategorySidebar({
    int perPage = 80,
    int currentPage = 1,
  }) async {
    try {
      final stored = LocationService.getStoredLocation();
      final latitude = stored?.latitude;
      final longitude = stored?.longitude;

      final Map<String, dynamic> query = {
        'per_page': perPage.toString(),
        'page': currentPage.toString(),
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        ApiRoutes.marketCategorySidebarApi,
        query,
      );
      return _asMap(response.data);
    } catch (e) {
      throw ApiException('Failed to fetch market categories');
    }
  }

  /// GET /market-categories/sub-categories — child markets.
  Future<Map<String, dynamic>> fetchMarketCategorySubCategories({
    required String slug,
    int perPage = 30,
    int currentPage = 1,
  }) async {
    try {
      final stored = LocationService.getStoredLocation();
      final latitude = stored?.latitude;
      final longitude = stored?.longitude;

      final Map<String, dynamic> query = {
        'slug': slug,
        'per_page': perPage.toString(),
        'page': currentPage.toString(),
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        ApiRoutes.marketCategorySubCategoriesApi,
        query,
      );
      return _asMap(response.data);
    } catch (e) {
      throw ApiException('Failed to fetch market sub-categories');
    }
  }

  /// GET /market-categories/search — search by query string.
  Future<Map<String, dynamic>> searchMarketCategories({
    required String query,
    int perPage = 30,
    int currentPage = 1,
  }) async {
    try {
      final stored = LocationService.getStoredLocation();
      final latitude = stored?.latitude;
      final longitude = stored?.longitude;

      final Map<String, dynamic> params = {
        'q': query,
        'per_page': perPage.toString(),
        'page': currentPage.toString(),
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        ApiRoutes.marketCategorySearchApi,
        params,
      );
      return _asMap(response.data);
    } catch (e) {
      throw ApiException('Failed to search market categories');
    }
  }

  /// GET `/delivery-zone/stores?market_category_slug=<slug>` — stores filtered
  /// by the given market category. Mirrors [NearByStoreRepo.getNearByStores]:
  /// returns null on missing location or network error so the detail page
  /// can degrade gracefully without taking the whole screen down.
  Future<Map<String, dynamic>?> fetchStoresByMarketCategorySlug({
    required String marketCategorySlug,
    int page = 1,
    int perPage = 24,
    String? searchQuery,
  }) async {
    try {
      final stored = LocationService.getStoredLocation();
      if (stored == null) {
        return null;
      }
      final latitude = stored.latitude;
      final longitude = stored.longitude;

      final Map<String, dynamic> query = {
        'latitude': latitude,
        'longitude': longitude,
        'page': page.toString(),
        'per_page': perPage.toString(),
        'market_category_slug': marketCategorySlug,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
      };

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        ApiRoutes.nearByStores,
        query,
      );

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data is Map<String, dynamic>) {
        log('API SUCCESS: Market stores fetched ($marketCategorySlug)');
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return <String, dynamic>{};
  }
}
