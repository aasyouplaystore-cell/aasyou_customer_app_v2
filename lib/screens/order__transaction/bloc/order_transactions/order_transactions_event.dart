part of 'order_transactions_bloc.dart';

abstract class OrderTransactionsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchOrderTransactions extends OrderTransactionsEvent {
  final String? search;
  final String? paymentStatus;

  FetchOrderTransactions({this.search, this.paymentStatus});

  @override
  List<Object?> get props => [search, paymentStatus];
}

class FetchMoreOrderTransactions extends OrderTransactionsEvent {
  @override
  List<Object?> get props => [];
}

class UpdateFilter extends OrderTransactionsEvent {
  final String? search;
  final String? paymentStatus;

  UpdateFilter({this.search, this.paymentStatus});

  @override
  List<Object?> get props => [search, paymentStatus];
}