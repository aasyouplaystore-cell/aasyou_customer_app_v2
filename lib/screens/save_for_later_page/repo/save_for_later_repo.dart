import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import '../../../config/helper.dart';
import '../../../services/location/location_service.dart';

class SaveForLaterRepository {
  Future<Map<String, dynamic>> fetchSavedProduct({
    required int perPage,
    required int currentPage,
  }) async {
    try{
      final locationService = LocationService.getStoredLocation();
      final latitude = locationService!.latitude;
      final longitude = locationService.longitude;

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        '${ApiRoutes.saveForLaterApi}?page=$currentPage&per_page=$perPage&latitude=$latitude&longitude=$longitude',
        {}
      );

      if(response.statusCode == 200) {
        return response.data;
      } else {
        return {};
      }
    }catch(e){
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> saveForLaterProduct({
    required int cartItemId,
  }) async {
    try{
      final response = await AppHelpers.apiBaseHelper.postAPICall(
          '${ApiRoutes.saveProductApi}$cartItemId',
          {}
      );
      if(response.statusCode == 200) {
        return response.data;
      } else {
        return {};
      }
    }catch(e){
      throw ApiException(e.toString());
    }
  }
}