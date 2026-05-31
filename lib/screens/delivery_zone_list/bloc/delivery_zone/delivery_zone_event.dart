part of 'delivery_zone_bloc.dart';

abstract class DeliveryZoneEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchDeliveryZones extends DeliveryZoneEvent {
  final int page;
  final int perPage;
  final String searchQuery;

  FetchDeliveryZones({
    this.page = 1,
    this.perPage = 15,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [page, perPage, searchQuery];
}

class LoadMoreDeliveryZones extends DeliveryZoneEvent {
  final int perPage;
  final String searchQuery;

  LoadMoreDeliveryZones({
    this.perPage = 15,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [perPage, searchQuery];
}
