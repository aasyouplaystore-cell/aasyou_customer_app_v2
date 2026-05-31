import 'package:aasyou/config/api_base_helper.dart';
import '../../../config/api_routes.dart';
import '../../../config/helper.dart';
import '../../../services/location/location_service.dart';

class BannerRepository {

  Future<Map<String, dynamic>> fetchBanners(
      {required String categorySlug}) async {
    try{
      final locationService = LocationService.getStoredLocation();
      final latitude = locationService!.latitude;
      final longitude = locationService.longitude;
      String apiUrl = '';
      if(categorySlug.isNotEmpty){
        apiUrl = '${ApiRoutes.bannerApi}?scope_category_slug=$categorySlug&latitude=$latitude&longitude=$longitude';
      } else {
        apiUrl = '${ApiRoutes.bannerApi}?latitude=$latitude&longitude=$longitude';
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
}