part of 'order_transactions_bloc.dart';

abstract class OrderTransactionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderTransactionsInitial extends OrderTransactionsState {}

class OrderTransactionsLoading extends OrderTransactionsState {}

class OrderTransactionsLoaded extends OrderTransactionsState {
  final List<OrderTransactionsDetail> transactions;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? currentSearch;
  final String? currentPaymentStatus;

  OrderTransactionsLoaded({
    required this.transactions,
    required this.hasReachedMax,
    required this.isLoadingMore,
    this.currentSearch,
    this.currentPaymentStatus,
  });

  @override
  List<Object?> get props => [transactions, hasReachedMax, isLoadingMore, currentSearch, currentPaymentStatus];
}

class OrderTransactionsFailure extends OrderTransactionsState {
  final String error;
  OrderTransactionsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}