import 'package:equatable/equatable.dart';

import '../../../near_by_stores/model/near_by_store_model.dart';

abstract class MarketCategoryStoresState extends Equatable {
  const MarketCategoryStoresState();
  @override
  List<Object?> get props => [];
}

class MarketCategoryStoresInitial extends MarketCategoryStoresState {}

class MarketCategoryStoresLoading extends MarketCategoryStoresState {}

class MarketCategoryStoresLoaded extends MarketCategoryStoresState {
  final String message;
  final NearbyStoresPageData stores;
  final bool hasReachedMax;
  final int totalStores;
  final bool isLoadingMore;

  const MarketCategoryStoresLoaded({
    required this.message,
    required this.stores,
    required this.totalStores,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props =>
      [message, stores, hasReachedMax, totalStores, isLoadingMore];
}

class MarketCategoryStoresFailed extends MarketCategoryStoresState {
  final String error;
  const MarketCategoryStoresFailed({required this.error});
  @override
  List<Object?> get props => [error];
}
