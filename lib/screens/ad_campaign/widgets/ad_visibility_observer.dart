import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../config/settings_data_instance.dart';
import '../bloc/ad_impression_bloc/ad_impression_bloc.dart';

class AdVisibilityObserver extends StatefulWidget {
  final int campaignId;
  final String visitorKey;
  final Widget child;

  const AdVisibilityObserver({
    super.key,
    required this.campaignId,
    required this.visitorKey,
    required this.child,
  });

  @override
  State<AdVisibilityObserver> createState() => _AdVisibilityObserverState();
}

class _AdVisibilityObserverState extends State<AdVisibilityObserver> {
  Timer? _dwellTimer;
  bool _impressionSent = false;

  double get _requiredVisibility =>
      (SettingsData.instance.advertisement?.adImpressionVisibilityPct ?? 50) /
      100.0;

  int get _requiredDwellMs =>
      SettingsData.instance.advertisement?.adImpressionVisibilityMs ?? 1000;

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_impressionSent) return;

    if (info.visibleFraction >= _requiredVisibility) {
      _dwellTimer ??= Timer(
        Duration(milliseconds: _requiredDwellMs),
        _recordImpression,
      );
    } else {
      _dwellTimer?.cancel();
      _dwellTimer = null;
    }
  }

  void _recordImpression() {
    if (_impressionSent) return;
    _impressionSent = true;
    _dwellTimer = null;
    context.read<AdImpressionBloc>().add(RecordImpression(
          campaignId: widget.campaignId,
          visitorKey: widget.visitorKey,
        ));
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('ad_${widget.campaignId}_${widget.visitorKey}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: widget.child,
    );
  }
}
