import 'package:equatable/equatable.dart';

abstract class MarketCategoryStoresEvent extends Equatable {
  const MarketCategoryStoresEvent();
  @override
  List<Object?> get props => [];
}

class FetchMarketCategoryStores extends MarketCategoryStoresEvent {
  final String marketCategorySlug;
  final int page;
  final int perPage;
  final String? searchQuery;

  const FetchMarketCategoryStores({
    required this.marketCategorySlug,
    this.page = 1,
    this.perPage = 24,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [marketCategorySlug, page, perPage, searchQuery];
}

class LoadMoreMarketCategoryStores extends MarketCategoryStoresEvent {
  final String marketCategorySlug;
  final int perPage;
  final String? searchQuery;

  const LoadMoreMarketCategoryStores({
    required this.marketCategorySlug,
    this.perPage = 24,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [marketCategorySlug, perPage, searchQuery];
}
