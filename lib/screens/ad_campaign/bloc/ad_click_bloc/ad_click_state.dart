part of 'ad_click_bloc.dart';

abstract class AdClickState extends Equatable {
  const AdClickState();

  @override
  List<Object?> get props => [];
}

class AdClickIdle extends AdClickState {
  const AdClickIdle();
}

class ClickRecorded extends AdClickState {
  final int campaignId;
  final String visitorKey;

  const ClickRecorded({
    required this.campaignId,
    required this.visitorKey,
  });

  @override
  List<Object?> get props => [campaignId, visitorKey];
}

class AdClickError extends AdClickState {
  final String error;

  const AdClickError({required this.error});

  @override
  List<Object?> get props => [error];
}
