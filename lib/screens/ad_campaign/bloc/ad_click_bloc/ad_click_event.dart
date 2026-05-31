part of 'ad_click_bloc.dart';

abstract class AdClickEvent extends Equatable {
  const AdClickEvent();

  @override
  List<Object?> get props => [];
}

class RecordClick extends AdClickEvent {
  final int campaignId;
  final String visitorKey;

  const RecordClick({
    required this.campaignId,
    required this.visitorKey,
  });

  @override
  List<Object?> get props => [campaignId, visitorKey];
}

class FlushClicks extends AdClickEvent {
  const FlushClicks();
}
