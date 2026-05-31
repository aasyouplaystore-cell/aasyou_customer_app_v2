part of 'delivery_zone_bloc.dart';

abstract class DeliveryZoneState extends Equatable{
  @override
  List<Object?> get props => [];
}

class DeliveryZoneInitial extends DeliveryZoneState {}

class DeliveryZoneLoading extends DeliveryZoneState {}

class DeliveryZoneLoaded extends DeliveryZoneState {
  final List<DeliveryZoneData> deliveryZoneData;
  final bool hasReachedMax;
  DeliveryZoneLoaded({required this.deliveryZoneData, required this.hasReachedMax});
  @override
  // TODO: implement props
  List<Object?> get props =>[deliveryZoneData, hasReachedMax];
}

class DeliveryZoneFailed extends DeliveryZoneState {
  final String error;

  DeliveryZoneFailed({required this.error});

  @override
  // TODO: implement props
  List<Object?> get props => [error];
}
