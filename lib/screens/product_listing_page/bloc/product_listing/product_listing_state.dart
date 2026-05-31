part of 'product_listing_bloc.dart';

abstract class ProductListingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductListingInitial extends ProductListingState {}

class ProductListingLoading extends ProductListingState {}

class ProductListingLoaded extends ProductListingState {
  final String message;
  final List<ProductData> productList;
  final bool hasReachedMax;
  final bool isFilterLoading;
  final SortType currentSortType;
  final int totalProducts;
  final bool isLoading;
  final List<dynamic>? keywords;
  final List<int>? categoryIds;
  final List<int>? brandIds;

  ProductListingLoaded({
    required this.message,
    required this.productList,
    required this.hasReachedMax,
    this.isFilterLoading = false,
    required this.isLoading,
    this.currentSortType = SortType.relevance,
    required this.totalProducts,
    this.keywords,
    this.categoryIds,
    this.brandIds
  });

  @override
  List<Object?> get props => [
    message,
    productList,
    hasReachedMax,
    isFilterLoading,
    currentSortType,
    totalProducts,
    isLoading,
    keywords,
    categoryIds,
    brandIds
  ];
}

class ProductListingFailed extends ProductListingState {
  final String error;
  ProductListingFailed({required this.error});

  @override
  List<Object?> get props => [error];
}