import 'package:equatable/equatable.dart';
import '../../../home_page/model/market_category_model.dart';

abstract class AllMarketCategoriesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllMarketCategoriesInitial extends AllMarketCategoriesState {}

class AllMarketCategoriesLoading extends AllMarketCategoriesState {}

class AllMarketCategoriesLoaded extends AllMarketCategoriesState {
  final List<MarketCategoryData> categoryData;
  final String message;
  final bool isLoadingMore;

  AllMarketCategoriesLoaded({
    required this.message,
    required this.categoryData,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [message, categoryData, isLoadingMore];
}

class AllMarketCategoriesFailed extends AllMarketCategoriesState {
  final String error;
  AllMarketCategoriesFailed({required this.error});

  @override
  List<Object?> get props => [error];
}
