import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import 'package:aasyou/model/sorting_model/sorting_model.dart';
import '../../../config/helper.dart';
import '../../../services/location/location_service.dart';
import '../model/product_listing_type.dart';

class CategoryProductRepository {

  Future<Map<String, dynamic>> fetchProductsByType({
    required ProductListingType type,
    required String identifier,
    String? storeSlug,
    String? sortType,
    required int perPage,
    required int currentPage,
    bool? isSearchInStore,
    String? includeChildCategories,
    required List<String> categorySlugs,
    required List<String> brandSlugs,
    List<int>? attributeIds,
  }) async {
    try {
      final latitude = LocationService.getStoredLocation()!.latitude;
      final longitude = LocationService.getStoredLocation()!.longitude;

      String buildListParam(String key, List<dynamic> values) {
        if (values.isEmpty) return '';
        return '&$key=${values.join(',')}';
      }

      final brandQuery = buildListParam('brands', brandSlugs);
      final categoryQuery = buildListParam('categories', categorySlugs);
      final attributeQuery = buildListParam('attribute_values', attributeIds!);

      final commonParams = '&per_page=$perPage'
          '&page=$currentPage'
          '&latitude=$latitude'
          '&longitude=$longitude'
          '&sort=${sortType ?? SortType.relevance}'
          '$brandQuery'
          '$categoryQuery'
          '$attributeQuery';

      String apiUrl = '';

      if (isSearchInStore == true && storeSlug != null) {
        apiUrl = '${ApiRoutes.searchApi}'
            '?search=$identifier'
            '&store=$storeSlug'
            '$commonParams';
      } else {
        apiUrl = switch (type) {
          ProductListingType.category => '${ApiRoutes.categoryProductApi}'
              '?categories=$identifier'
              '$commonParams'
              '&include_child_categories=${includeChildCategories ?? '1'}',

          ProductListingType.brand => '${ApiRoutes.categoryProductApi}'
              '?brands=$identifier'
              '$commonParams',

          ProductListingType.store => '${ApiRoutes.storeProductApi}'
              '?store=$storeSlug'
              '$commonParams',

          ProductListingType.search => '${ApiRoutes.searchApi}'
              '?search=$identifier'
              '$commonParams',

          ProductListingType.featuredSection =>
              '${ApiRoutes.specificFeatureSectionProductApi}'
                  '$identifier/products'
                  '?$commonParams'.replaceFirst(
                  '?&', '?'),
        };
      }

      final response = await AppHelpers.apiBaseHelper.getAPICall(apiUrl, {});

      // Browse-only fallback for shared STORE links: the zone-scoped grid is
      // empty when the viewer is outside the store's delivery area, but the
      // store's own catalog still exists — fetch it location-free so the
      // page shows products (ordering stays gated elsewhere). For a genuinely
      // empty in-zone store both calls return nothing, so this is harmless.
      if (type == ProductListingType.store &&
          storeSlug != null &&
          (isSearchInStore != true)) {
        final inner = response.data['data'];
        final rows = inner is Map<String, dynamic> ? inner['data'] : null;
        if (rows is List && rows.isEmpty) {
          final fallback = await AppHelpers.apiBaseHelper.getAPICall(
            '${ApiRoutes.storeWiseProductApi}'
            '?store_slug=$storeSlug&per_page=$perPage&page=$currentPage',
            {},
          );
          return fallback.data;
        }
      }

      return response.data;

    } catch (e) {
      throw ApiException(e.toString());
    }
  }


  Future<Map<String, dynamic>> fetchFilterProduct({
    List<String>? categorySlugs,
    List<String>? brandSlugs,
    List<int>? attributeValueIds,
    ProductListingType? contextType,
    String? contextValue,

  }) async {
    try{
      final locationService = LocationService.getStoredLocation();

      final latitude = locationService!.latitude;
      final longitude = locationService.longitude;

      // Build query parameters
      final queryParams = <String, dynamic>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      if (categorySlugs != null && categorySlugs.isNotEmpty) {
        queryParams['categories'] = categorySlugs.join(',');
      }
      if (brandSlugs != null && brandSlugs.isNotEmpty) {
        queryParams['brands'] = brandSlugs.join(',');
      }
      if (attributeValueIds != null && attributeValueIds.isNotEmpty) {
        queryParams['attribute_values'] = attributeValueIds.join(',');
      }

      if (contextType != null) {
        if(ProductListingType.featuredSection == contextType){
          queryParams['type'] = 'featured_section';
        } else {
          queryParams['type'] = contextType.name;
        }

        if (contextValue != null && contextValue.isNotEmpty) {
          queryParams['value'] = contextValue;
        }
      }

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        ApiRoutes.filterProductApi,
        queryParams,
      );
      return response.data;
    }catch(e){
      throw ApiException('Failed to fetch categories');
    }
  }


}
