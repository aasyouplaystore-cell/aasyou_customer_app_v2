import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import 'package:aasyou/config/helper.dart';

import '../model/ad_tracking_event.dart';
import '../model/ad_tracking_response.dart';

class AdCampaignRepo {

  Future<AdTrackingResponse> postImpressionBatch(List<AdTrackingEvent> events) async {
    try{
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.adBulkImpressionsApi,
        {
          'events': events.map((e) => e.toJson()).toList()
        },
      );
      return AdTrackingResponse.fromJson(response.data as Map<String, dynamic>);
    } catch(e){
      throw ApiException(e.toString());
    }
  }

  Future<AdTrackingResponse> postClickBatch(List<AdTrackingEvent> events) async {
    try{
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.adBulkClicksApi,
        {
          'events': events.map((e) => e.toJson()).toList()
        },
      );
      return AdTrackingResponse.fromJson(response.data as Map<String, dynamic>);
    } catch(e) {
      throw ApiException(e.toString());
    }
  }
}
