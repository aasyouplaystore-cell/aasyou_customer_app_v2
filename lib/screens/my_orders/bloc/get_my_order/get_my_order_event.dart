import 'package:equatable/equatable.dart';

abstract class GetMyOrderEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchMyOrder extends GetMyOrderEvent {
  final String? dateFilter;
  final String? statusSort;
  final String? billing; // online | offline | khata
  FetchMyOrder({this.dateFilter, this.statusSort, this.billing});
  @override
  // TODO: implement props
  List<Object?> get props => [dateFilter, statusSort, billing];
}

class FetchMoreMyOrder extends GetMyOrderEvent {
  final String? dateFilter;
  final String? statusSort;
  final String? billing;
  FetchMoreMyOrder({this.dateFilter, this.statusSort, this.billing});
  @override
  // TODO: implement props
  List<Object?> get props => [dateFilter, statusSort, billing];
}

class RefreshMyOrders extends GetMyOrderEvent {
  final String? dateFilter;
  final String? statusSort;
  final String? billing;
  RefreshMyOrders({this.dateFilter, this.statusSort, this.billing});
  @override
  // TODO: implement props
  List<Object?> get props => [dateFilter, statusSort];
}

class UpdateDateFilter extends GetMyOrderEvent {
  final String dateFilter;
  UpdateDateFilter({required this.dateFilter});

  @override
  // TODO: implement props
  List<Object?> get props => [dateFilter];
}

class UpdateStatusFilter extends GetMyOrderEvent {
  final String statusFilter;
  UpdateStatusFilter({required this.statusFilter});

  @override
  // TODO: implement props
  List<Object?> get props => [statusFilter];
}

class ClearDateFilter extends GetMyOrderEvent {}

class ClearStatusFilter extends GetMyOrderEvent {}