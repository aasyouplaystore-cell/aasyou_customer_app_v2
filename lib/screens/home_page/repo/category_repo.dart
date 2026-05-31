import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import '../../../config/helper.dart';
import '../../../services/location/location_service.dart';

class CategoryRepository {
  Future<Map<String, dynamic>> fetchCategory({
    required int perPage,
    required int currentPage,
}) async {
    try{
      final locationService = LocationService.getStoredLocation();
      final latitude = locationService!.latitude;
      final longitude = locationService.longitude;
      final response = await AppHelpers.apiBaseHelper.getAPICall(
        '${ApiRoutes.categoryApi}?per_page=$perPage&page=$currentPage&latitude=$latitude&longitude=$longitude&home=true',
        {}
      );
      return response.data;
    }catch(e){
      throw ApiException('Failed to fetch categories');
    }
  }

  Future<Map<String, dynamic>> fetchFilterCategory({
    required int perPage,
    required int currentPage,
    List<int>? categoryIds,
  }) async {
    try{
      final locationService = LocationService.getStoredLocation();
      final latitude = locationService!.latitude;
      final longitude = locationService.longitude;

      final queryParams = <String, dynamic>{
        'per_page': perPage.toString(),
        'page': currentPage.toString(),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'home': 'true',

      };

      if (categoryIds != null && categoryIds.isNotEmpty) {
        queryParams['ids[]'] = categoryIds.map((id) => id.toString()).toList();
      }

      final response = await AppHelpers.apiBaseHelper.getAPICall(
          ApiRoutes.filterCategoryApi,
          queryParams,
      );
      return response.data;
    }catch(e){
      throw ApiException('Failed to fetch categories');
    }
  }
}