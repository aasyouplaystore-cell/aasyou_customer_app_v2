import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/ad_tracking/ad_tracking_service.dart';
import '../../model/ad_tracking_event.dart';

part 'ad_impression_event.dart';
part 'ad_impression_state.dart';

class AdImpressionBloc extends Bloc<AdImpressionEvent, AdImpressionState> {
  AdImpressionBloc({required AdTrackingService trackingService})
      : _trackingService = trackingService,
        super(const AdImpressionIdle()) {
    on<RecordImpression>(_onRecordImpression);
    on<FlushImpressions>(_onFlushImpressions);
  }

  final AdTrackingService _trackingService;

  Future<void> _onRecordImpression(
    RecordImpression event,
    Emitter<AdImpressionState> emit,
  ) async {
    try {
      final trackingEvent = AdTrackingEvent(
        campaignId: event.campaignId,
        visitorKey: event.visitorKey,
        timestamp: DateTime.now(),
      );
      await _trackingService.sendImpressions([trackingEvent]);
      emit(ImpressionRecorded(
        campaignId: event.campaignId,
        visitorKey: event.visitorKey,
      ));
    } catch (e) {
      emit(AdImpressionError(error: e.toString()));
    }
  }

  Future<void> _onFlushImpressions(
    FlushImpressions event,
    Emitter<AdImpressionState> emit,
  ) async {
    try {
      await _trackingService.flushAll();
    } catch (_) {}
  }
}
