part of 'delivery_zone_detail_bloc.dart';

abstract class DeliveryZoneDetailEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}


class FetchDeliveryZoneDetail extends DeliveryZoneDetailEvent {
  final int zoneId;

  FetchDeliveryZoneDetail({required this.zoneId});

  @override
  // TODO: implement props
  List<Object?> get props => [zoneId];
}