part of 'ad_impression_bloc.dart';

abstract class AdImpressionEvent extends Equatable {
  const AdImpressionEvent();

  @override
  List<Object?> get props => [];
}

class RecordImpression extends AdImpressionEvent {
  final int campaignId;
  final String visitorKey;

  const RecordImpression({
    required this.campaignId,
    required this.visitorKey,
  });

  @override
  List<Object?> get props => [campaignId, visitorKey];
}

class FlushImpressions extends AdImpressionEvent {
  const FlushImpressions();
}
