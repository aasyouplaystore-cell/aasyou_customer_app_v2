import '../../../config/api_base_helper.dart';
import '../../../config/api_routes.dart';
import '../../../config/helper.dart';
import '../../../services/location/location_service.dart';

class BrandsRepository {

  Future<Map<String, dynamic>> fetchBrands(
      {required String categorySlug,
      }) async {
    try{
      final locationService = LocationService.getStoredLocation();
      final latitude = locationService!.latitude;
      final longitude = locationService.longitude;
      String apiUrl = '';

      if(categorySlug.isNotEmpty){
        apiUrl = '${ApiRoutes.brandsApi}?scope_category_slug=$categorySlug&latitude=$latitude&longitude=$longitude';
      } else {
        apiUrl = '${ApiRoutes.brandsApi}?latitude=$latitude&longitude=$longitude';
      }
      final response = await AppHelpers.apiBaseHelper.getAPICall(
          apiUrl,
          {}
      );
      return response.data;
    }catch(e){
      throw ApiException('Failed to fetch Banners');
    }
  }

  Future<Map<String, dynamic>> fetchFilterBrands(
      {required String categorySlug,
        required List<int>? brandIds
      }) async {
    try{
      final locationService = LocationService.getStoredLocation();
      final latitude = locationService!.latitude;
      final longitude = locationService.longitude;

      final queryParams = <String, dynamic>{
        'scope_category_slug': categorySlug.toString(),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      if (brandIds != null && brandIds.isNotEmpty) {
        queryParams['ids[]'] = brandIds.map((id) => id.toString()).toList();
      }

      final response = await AppHelpers.apiBaseHelper.getAPICall(
          ApiRoutes.filterBrandsApi,
          {
            'ids[]': brandIds
          }
      );
      return response.data;
    }catch(e){
      throw ApiException('Failed to fetch Banners');
    }
  }
}