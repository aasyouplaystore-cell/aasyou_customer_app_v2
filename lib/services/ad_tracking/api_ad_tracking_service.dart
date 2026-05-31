import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../screens/ad_campaign/model/ad_tracking_event.dart';
import '../../screens/ad_campaign/model/ad_tracking_response.dart';
import '../../screens/ad_campaign/repo/ad_campaign_repo.dart';
import 'ad_tracking_service.dart';

class ApiAdTrackingService implements AdTrackingService {
  ApiAdTrackingService({required AdCampaignRepo repo}) : _repo = repo;

  final AdCampaignRepo _repo;
  final List<AdTrackingEvent> _impressionBuffer = [];
  final List<AdTrackingEvent> _clickBuffer = [];
  final Set<String> _setClickKeys = {};
  final Set<String> _sentImpressionKeys = {};

  Timer? _flushTimer;
  bool _isDisposed = false;

  static const Duration _flushInterval = Duration(seconds: 60);

  void _ensureTimerRunning() {
    log('Flush Timer');
    if (_isDisposed || _flushTimer?.isActive == true) return;
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flushAll());
  }

  @override
  Future<AdTrackingResponse> sendImpressions(List<AdTrackingEvent> events) async {
    for (final event in events) {
      final key = '${event.campaignId}_${event.visitorKey}';
      if (_sentImpressionKeys.contains(key)) continue;
      _sentImpressionKeys.add(key);
      _impressionBuffer.add(event);
    }
    _ensureTimerRunning();
    return AdTrackingResponse(
      success: true,
      message: 'buffered',
      data: []
    );
  }

  @override
  Future<AdTrackingResponse> sendClicks(List<AdTrackingEvent> events) async {
    for(final event in events) {
      final key = '${event.campaignId}_${event.visitorKey}';
      if(_setClickKeys.contains(key)) continue;
      _setClickKeys.add(key);
      _clickBuffer.add(event);
    }
    _ensureTimerRunning();
    return AdTrackingResponse(
      success: true,
      message: 'buffered',
      data: [],
    );
  }

  Future<void> _flushAll() async {
    log('Flush All Event 🚀');
    await _flushImpressions();
    await _flushClicks();

    if (_impressionBuffer.isEmpty && _clickBuffer.isEmpty) {
      _flushTimer?.cancel();
      _flushTimer = null;
    }
  }

  Future<void> _flushImpressions() async {
    if (_impressionBuffer.isEmpty) return;
    final batch = List<AdTrackingEvent>.from(_impressionBuffer);
    _impressionBuffer.clear();
    try {
      await _repo.postImpressionBatch(batch);
    } catch (e, error) {
      debugPrint('Ad impression flush failed: ${error.toString()}');
    }
  }

  Future<void> _flushClicks() async {
    if (_clickBuffer.isEmpty) return;
    final batch = List<AdTrackingEvent>.from(_clickBuffer);
    _clickBuffer.clear();
    try {
      await _repo.postClickBatch(batch);
    } catch (e) {
      debugPrint('Ad click flush failed: $e');
    }
  }

  @override
  Future<void> flushAll() async {
    await _flushAll();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _flushTimer?.cancel();
    _flushTimer = null;
    _flushAll();
  }
}
