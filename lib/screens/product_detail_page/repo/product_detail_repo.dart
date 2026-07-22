import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import '../../../services/location/location_service.dart';

class ProductDetailRepository {
  final ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  Future<Map<String, dynamic>> fetchProductDetail({required String productSlug}) async {
    try{
      // Coords are optional server-side now: a shared link opened before any
      // location exists (or outside every zone) still returns the product
      // with is_deliverable=false — no more null-bang crash / dead page.
      final locationService = LocationService.getStoredLocation();
      final query = locationService != null
          ? '?latitude=${locationService.latitude}&longitude=${locationService.longitude}'
          : '';
      final response = await apiBaseHelper.getAPICall(
        '${ApiRoutes.productDetailApi}$productSlug$query', {}
      );
      return response.data;
    }catch(e){
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> fetchSimilarProduct({required List<String> excludeProductSlug}) async {
    try{
      final locationService = LocationService.getStoredLocation();
      final latitude = locationService!.latitude;
      final longitude = locationService.longitude;

      String apiUrl = '';
      if(excludeProductSlug.isNotEmpty){
        String excludeParam = excludeProductSlug.join(",");
        apiUrl = '${ApiRoutes.getSimilarProductApi}?exclude_product=$excludeParam&latitude=$latitude&longitude=$longitude';
      } else {
        apiUrl = '${ApiRoutes.getSimilarProductApi}?latitude=$latitude&longitude=$longitude';
      }
      final response = await apiBaseHelper.getAPICall(
          apiUrl,
          {}
      );
      return response.data;
    } catch(e){
      throw ApiException('Failed to fetch similar product');
    }
  }
}