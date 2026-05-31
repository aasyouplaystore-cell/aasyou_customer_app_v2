import 'package:equatable/equatable.dart';

import '../../model/my_order_model.dart';

abstract class GetMyOrderState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetMyOrderInitial extends GetMyOrderState {}

class GetMyOrderDemo extends GetMyOrderState {}

class GetMyOrderLoading extends GetMyOrderState {}

class GetMyOrderLoaded extends GetMyOrderState {
  final String message;
  final List<MyOrderData> myOrderData;
  final bool hasReachedMax;
  final bool isRefreshing;
  final bool isLoadingMore;

  GetMyOrderLoaded({
    required this.message,
    required this.myOrderData,
    required this.hasReachedMax,
    this.isRefreshing = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        message,
        myOrderData,
        hasReachedMax,
        isRefreshing,
        isLoadingMore,
      ];

  GetMyOrderLoaded copyWith({
    String? message,
    List<MyOrderData>? myOrderData,
    bool? hasReachedMax,
    bool? isRefreshing,
    bool? isLoadingMore,
  }) {
    return GetMyOrderLoaded(
      message: message ?? this.message,
      myOrderData: myOrderData ?? this.myOrderData,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class GetMyOrderFailed extends GetMyOrderState {
  final String error;

  GetMyOrderFailed({required this.error});

  @override
  // TODO: implement props
  List<Object?> get props => [error];
}
