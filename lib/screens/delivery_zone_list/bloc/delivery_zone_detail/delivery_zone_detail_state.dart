part of 'delivery_zone_detail_bloc.dart';

abstract class DeliveryZoneDetailState extends Equatable{
  @override
  List<Object?> get props => [];
}

class DeliveryZoneDetailInitial extends DeliveryZoneDetailState {}



class DeliveryZoneDetailLoading extends DeliveryZoneDetailState {}

class DeliveryZoneDetailLoaded extends DeliveryZoneDetailState {
  final DeliveryZoneDetailData deliveryZoneDetail;
  DeliveryZoneDetailLoaded({required this.deliveryZoneDetail});
  @override
  // TODO: implement props
  List<Object?> get props =>[deliveryZoneDetail];
}

class DeliveryZoneDetailFailed extends DeliveryZoneDetailState {
  final String error;

DeliveryZoneDetailFailed({required this.error});

  @override
  // TODO: implement props
  List<Object?> get props => [error];
}

