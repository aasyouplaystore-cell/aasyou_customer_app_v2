import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/my_order_model.dart';
import '../../repo/order_repo.dart';
import 'get_my_order_event.dart';
import 'get_my_order_state.dart';

class GetMyOrderBloc extends Bloc<GetMyOrderEvent, GetMyOrderState> {
  GetMyOrderBloc() : super(GetMyOrderInitial()) {
    on<FetchMyOrder>(_onFetchMyOrder);
    on<FetchMoreMyOrder>(_onFetchMoreMyOrder);
    on<UpdateDateFilter>(_onUpdateDateFilter);
    on<UpdateStatusFilter>(_onUpdateStatusFilter);
    on<ClearStatusFilter>(_onClearStatusFilter);
    on<ClearDateFilter>(_onClearDateFilter);
    on<RefreshMyOrders>(_onRefreshMyOrders);
  }

  int currentPage = 1;
  int perPage = 15;
  bool _hasReachedMax = false;
  bool isLoadingMore = false;
  final OrderRepository repository = OrderRepository();
  String selectedDateFilter = '';
  String selectedStatusFilter = '';

  Future<void> _onFetchMyOrder(FetchMyOrder event, Emitter<GetMyOrderState> emit,) async {
    emit(GetMyOrderLoading());
    await _fetchOrders(emit, event.dateFilter ?? '', event.statusSort ?? '', isRefresh: false);
  }

  // NEW: Refresh without showing full loading
  Future<void> _onRefreshMyOrders(RefreshMyOrders event, Emitter<GetMyOrderState> emit,) async {
    if (state is GetMyOrderLoaded) {
      await _fetchOrders(emit, event.dateFilter ?? '', event.statusSort ?? '', isRefresh: true);
    } else {
      emit(GetMyOrderLoading());
      await _fetchOrders(emit, event.dateFilter ?? '', event.statusSort ?? '', isRefresh: false);
    }
  }

  /// Core fetch logic (used by both initial & refresh)
  Future<void> _fetchOrders(Emitter<GetMyOrderState> emit,  String dateFilter, String statusFilter, {required bool isRefresh,}) async {
    try {
      // Reset pagination only on refresh or initial load
      if (isRefresh || state is! GetMyOrderLoaded) {
        currentPage = 1;
        _hasReachedMax = false;
        isLoadingMore = false;
      }

      final response = await repository.fetchMyOrderList(
        page: currentPage,
        perPage: perPage,
        dateFilter: dateFilter,
        statusFilter: statusFilter,
      );

      final newOrders = List<MyOrderData>.from(
        (response['data']['data'] as List).map((e) => MyOrderData.fromJson(e)),
      );

      final currentPageNum =
          int.tryParse(response['data']['current_page'].toString()) ?? 1;
      final lastPageNum =
          int.tryParse(response['data']['last_page'].toString()) ?? 1;
      _hasReachedMax =
          currentPageNum >= lastPageNum || newOrders.length < perPage;

      log('Updated Order Data  ${newOrders.length}');

      if (response['success'] == true) {
        emit(GetMyOrderLoaded(
          message: response['message'] ?? 'Orders loaded successfully',
          myOrderData: newOrders,
          hasReachedMax: _hasReachedMax,
        ));
      } else {
        emit(GetMyOrderFailed(
            error: response['message'] ?? 'Failed to load orders'));
      }
    } catch (e) {
      emit(GetMyOrderFailed(error: e.toString()));
    }
  }

  /// Load more orders
  Future<void> _onFetchMoreMyOrder(FetchMoreMyOrder event, Emitter<GetMyOrderState> emit) async {
    // Prevent multiple simultaneous calls
    if (_hasReachedMax || isLoadingMore) return;

    final currentState = state;
    if (currentState is GetMyOrderLoaded) {
      // Set loading state in Bloc and emit Updated state to show loader in UI
      isLoadingMore = true;
      emit(currentState.copyWith(isLoadingMore: true));

      try {
        // Increment page BEFORE API call
        currentPage += 1;
        final response = await repository.fetchMyOrderList(
          page: currentPage,
          perPage: perPage,
          dateFilter: selectedDateFilter,
          statusFilter: selectedStatusFilter
        );

        if (response['success'] == true && response['data'] != null) {
          final newOrderData = List<MyOrderData>.from(
              (response['data']['data'] as List)
                  .map((data) => MyOrderData.fromJson(data)));

          // Update hasReachedMax
          final currentTotal =
              int.tryParse(response['data']['current_page'].toString()) ??
                  currentPage;
          final lastPageNum =
              int.tryParse(response['data']['last_page'].toString()) ??
                  currentPage;
          _hasReachedMax =
              currentTotal >= lastPageNum || newOrderData.length < perPage;


          // Combine lists ensuring uniqueness
          final updatedOrderData =
              List<MyOrderData>.from(currentState.myOrderData);
          for (final newOrder in newOrderData) {
            if (!updatedOrderData
                .any((existing) => existing.id == newOrder.id)) {
              updatedOrderData.add(newOrder);
            }
          }

          log('Updated Order Data From Fetch More ${updatedOrderData.length}');
          emit(GetMyOrderLoaded(
            message: response['message'] ?? currentState.message,
            myOrderData: updatedOrderData,
            hasReachedMax: _hasReachedMax,
            isLoadingMore: false,
          ));
        } else {
          // If API fails but we have existing data, don't clear it
          currentPage -= 1; // Revert page increment
          emit(currentState.copyWith(isLoadingMore: false));
          log('Fetch more failed: ${response['message']}');
        }
      } catch (e) {
        log('Error in FetchMoreMyOrder: $e');
        // Reset page on error and keep current data
        currentPage -= 1;
        emit(currentState.copyWith(isLoadingMore: false));
      } finally {
        isLoadingMore = false;
      }
    }
  }

  /// Update Date Filter
  Future<void> _onUpdateDateFilter(UpdateDateFilter event, Emitter<GetMyOrderState> emit) async {
    try{
      selectedDateFilter = event.dateFilter;
      add(FetchMyOrder());
    } catch (e) {
      emit(GetMyOrderFailed(error: e.toString()));
    }
  }

  Future<void> _onUpdateStatusFilter(UpdateStatusFilter event, Emitter<GetMyOrderState> emit) async {
    try{
      selectedStatusFilter = event.statusFilter;
      add(FetchMyOrder());
    } catch (e) {
      emit(GetMyOrderFailed(error: e.toString()));
    }
  }

  Future<void> _onClearStatusFilter(ClearStatusFilter event, Emitter<GetMyOrderState> emit) async {
    selectedStatusFilter = '';
    add(FetchMyOrder());
  }

  Future<void> _onClearDateFilter(ClearDateFilter event, Emitter<GetMyOrderState> emit) async {
    selectedDateFilter = '';
    add(FetchMyOrder());
  }
}
