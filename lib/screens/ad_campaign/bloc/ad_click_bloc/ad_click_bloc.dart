import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/ad_tracking/ad_tracking_service.dart';
import '../../model/ad_tracking_event.dart';

part 'ad_click_event.dart';
part 'ad_click_state.dart';

class AdClickBloc extends Bloc<AdClickEvent, AdClickState> {
  AdClickBloc({required AdTrackingService trackingService})
      : _trackingService = trackingService,
        super(const AdClickIdle()) {
    on<RecordClick>(_onRecordClick);
    on<FlushClicks>(_onFlushClicks);
  }

  final AdTrackingService _trackingService;

  Future<void> _onRecordClick(
    RecordClick event,
    Emitter<AdClickState> emit,
  ) async {
    try {
      final trackingEvent = AdTrackingEvent(
        campaignId: event.campaignId,
        visitorKey: event.visitorKey,
        timestamp: DateTime.now(),
      );
      await _trackingService.sendClicks([trackingEvent]);
      emit(ClickRecorded(
        campaignId: event.campaignId,
        visitorKey: event.visitorKey,
      ));
    } catch (e) {
      emit(AdClickError(error: e.toString()));
    }
  }

  Future<void> _onFlushClicks(
    FlushClicks event,
    Emitter<AdClickState> emit,
  ) async {
    try {
      await _trackingService.flushAll();
    } catch (_) {}
  }
}
