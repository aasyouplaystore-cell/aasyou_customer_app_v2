import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../model/order_transaction_model.dart';
import '../../repo/order_repository.dart';
part 'order_transactions_event.dart';
part 'order_transactions_state.dart';

class OrderTransactionsBloc extends Bloc<OrderTransactionsEvent, OrderTransactionsState> {
  OrderTransactionsBloc() : super(OrderTransactionsInitial()) {
    on<FetchOrderTransactions>(_onFetchOrderTransactions);
    on<FetchMoreOrderTransactions>(_onFetchMoreOrderTransactions);
    on<UpdateFilter>(_onUpdateFilter);
  }

  final repository = OrderTransactionRepository();

  int currentPage = 1;
  int perPage = 10;
  bool hasReachedMax = false;
  bool isLoadingMore = false;

  String? _currentSearch;
  String? _currentPaymentStatus;

  Future<void> _onUpdateFilter(UpdateFilter event, Emitter<OrderTransactionsState> emit) async {
    _currentSearch = event.search;
    _currentPaymentStatus = event.paymentStatus;

    add(FetchOrderTransactions(
      search: _currentSearch,
      paymentStatus: _currentPaymentStatus,
    ));
  }

  Future<void> _onFetchOrderTransactions(FetchOrderTransactions event, Emitter<OrderTransactionsState> emit) async {
    emit(OrderTransactionsLoading());

    try {
      currentPage = 1;
      hasReachedMax = false;
      isLoadingMore = false;

      _currentSearch = event.search;
      _currentPaymentStatus = event.paymentStatus;

      final response = await repository.fetchOrderTransactions(
        page: currentPage,
        perPage: perPage,
        search: _currentSearch,
        paymentStatus: _currentPaymentStatus,
      );

      final transactions = List<OrderTransactionsDetail>.from(
        (response['data']?['data'] ?? []).map((data) => OrderTransactionsDetail.fromJson(data)),
      );

      final lastPage = int.tryParse(response['data']?['last_page']?.toString() ?? '1') ?? 1;
      final currentPageFromApi = int.tryParse(response['data']?['current_page']?.toString() ?? '1') ?? 1;

      hasReachedMax = currentPageFromApi >= lastPage || transactions.length < perPage;

      emit(OrderTransactionsLoaded(
        transactions: transactions,
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
        currentSearch: _currentSearch,
        currentPaymentStatus: _currentPaymentStatus,
      ));
    } catch (e) {
      emit(OrderTransactionsFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchMoreOrderTransactions(FetchMoreOrderTransactions event, Emitter<OrderTransactionsState> emit) async {
    if (hasReachedMax || isLoadingMore) return;

    final currentState = state;
    if (currentState is! OrderTransactionsLoaded) return;

    isLoadingMore = true;

    try {
      currentPage += 1;

      final response = await repository.fetchOrderTransactions(
        page: currentPage,
        perPage: perPage,
        search: _currentSearch,
        paymentStatus: _currentPaymentStatus,
      );

      final newTransactions = List<OrderTransactionsDetail>.from(
        (response['data']?['data'] ?? []).map((data) => OrderTransactionsDetail.fromJson(data)),
      );

      final lastPage = int.tryParse(response['data']?['last_page']?.toString() ?? '1') ?? 1;
      hasReachedMax = currentPage >= lastPage || newTransactions.length < perPage;

      final updatedList = List<OrderTransactionsDetail>.from(currentState.transactions);

      for (final tx in newTransactions) {
        if (!updatedList.any((existing) => existing.id == tx.id)) {
          updatedList.add(tx);
        }
      }

      emit(OrderTransactionsLoaded(
        transactions: updatedList,
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
        currentSearch: _currentSearch,
        currentPaymentStatus: _currentPaymentStatus,
      ));
    } catch (e) {
      currentPage -= 1;
      emit(OrderTransactionsFailure(error: e.toString()));
    } finally {
      isLoadingMore = false;
    }
  }
}