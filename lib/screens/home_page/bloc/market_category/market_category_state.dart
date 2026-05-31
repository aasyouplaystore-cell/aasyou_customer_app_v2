import 'package:equatable/equatable.dart';
import 'package:aasyou/screens/home_page/model/market_category_model.dart';

abstract class HomeMarketCategoriesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeMarketCategoriesInitial extends HomeMarketCategoriesState {}

class HomeMarketCategoriesLoading extends HomeMarketCategoriesState {}

class HomeMarketCategoriesLoaded extends HomeMarketCategoriesState {
  final List<MarketCategoryData> categoryData;
  final String message;
  final bool hasReachedMax;

  HomeMarketCategoriesLoaded({
    required this.message,
    required this.categoryData,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [message, categoryData, hasReachedMax];
}

class HomeMarketCategoriesFailed extends HomeMarketCategoriesState {
  final String error;
  HomeMarketCategoriesFailed({required this.error});

  @override
  List<Object?> get props => [error];
}
