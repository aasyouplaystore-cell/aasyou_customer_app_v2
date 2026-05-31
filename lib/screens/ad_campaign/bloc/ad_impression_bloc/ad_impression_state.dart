part of 'ad_impression_bloc.dart';

abstract class AdImpressionState extends Equatable {
  const AdImpressionState();

  @override
  List<Object?> get props => [];
}

class AdImpressionIdle extends AdImpressionState {
  const AdImpressionIdle();
}

class ImpressionRecorded extends AdImpressionState {
  final int campaignId;
  final String visitorKey;

  const ImpressionRecorded({
    required this.campaignId,
    required this.visitorKey,
  });

  @override
  List<Object?> get props => [campaignId, visitorKey];
}

class AdImpressionError extends AdImpressionState {
  final String error;

  const AdImpressionError({required this.error});

  @override
  List<Object?> get props => [error];
}
