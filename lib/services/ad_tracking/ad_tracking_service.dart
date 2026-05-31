import '../../screens/ad_campaign/model/ad_tracking_event.dart';
import '../../screens/ad_campaign/model/ad_tracking_response.dart';

abstract class AdTrackingService {
  Future<AdTrackingResponse> sendImpressions(List<AdTrackingEvent> events);
  Future<AdTrackingResponse> sendClicks(List<AdTrackingEvent> events);
  Future<void> flushAll();
  void dispose();
}
