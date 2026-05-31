import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/screens/delivery_zone_list/model/delivery_zone_detail_model.dart';

import '../../../config/api_routes.dart';
import '../../../config/helper.dart';

class DeliveryZoneRepository {
  Future<Map<String, dynamic>> fetchDeliveryZone({
    required int page,
    required int perPage,
    String searchQuery = '',
  }) async {
    try {
      final response = await AppHelpers.apiBaseHelper.getAPICall(
          '${ApiRoutes.deliveryZonesApi}?page=$page&per_page=$perPage&search=$searchQuery',
          {});

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(response.data['message']);
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<DeliveryZoneDetailModel>> fetchDeliveryZoneDetail(
      {required int deliveryZoneId}) async {
    try {
      final response = await AppHelpers.apiBaseHelper
          .getAPICall('${ApiRoutes.deliveryZoneDetailApi}$deliveryZoneId', {});

      if (response.statusCode == 200) {
        List<DeliveryZoneDetailModel> deliveryZoneDetail = [];
        deliveryZoneDetail
            .add(DeliveryZoneDetailModel.fromJson((response.data)));
        return deliveryZoneDetail;
      } else {
        throw ApiException(response.data['message']);
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
