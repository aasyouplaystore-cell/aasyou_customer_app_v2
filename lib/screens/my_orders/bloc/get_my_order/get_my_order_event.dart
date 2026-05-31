import 'package:equatable/equatable.dart';

abstract class GetMyOrderEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchMyOrder extends GetMyOrderEvent {
  final String? dateFilter;
  final String? statusSort;
  FetchMyOrder({this.dateFilter, this.statusSort});
  @override
  // TODO: implement props
  List<Object?> get props => [dateFilter, statusSort];
}

class FetchMoreMyOrder extends GetMyOrderEvent {
  final String? dateFilter;
  final String? statusSort;
  FetchMoreMyOrder({this.dateFilter, this.statusSort});
  @override
  // TODO: implement props
  List<Object?> get props => [dateFilter, statusSort];
}

class RefreshMyOrders extends GetMyOrderEvent {
  final String? dateFilter;
  final String? statusSort;
  RefreshMyOrders({this.dateFilter, this.statusSort});
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