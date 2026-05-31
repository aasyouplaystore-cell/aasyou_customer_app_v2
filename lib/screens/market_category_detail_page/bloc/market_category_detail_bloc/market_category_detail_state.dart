import 'package:equatable/equatable.dart';

import '../../../home_page/model/market_category_model.dart';

abstract class MarketCategoryDetailState extends Equatable {
  const MarketCategoryDetailState();
  @override
  List<Object?> get props => [];
}

class MarketCategoryDetailInitial extends MarketCategoryDetailState {}

class MarketCategoryDetailLoading extends MarketCategoryDetailState {}

class MarketCategoryDetailLoaded extends MarketCategoryDetailState {
  /// Parent market category (from `main_category_data`). Holds the banner,
  /// title, description, store_count, etc. used by the hero header.
  final MarketCategoryData? mainCategory;

  /// Children markets (sub-categories) for the recursive drill-down grid.
  final List<MarketCategoryData> subcategories;
  final String message;

  const MarketCategoryDetailLoaded({
    required this.mainCategory,
    required this.subcategories,
    required this.message,
  });

  @override
  List<Object?> get props => [mainCategory, subcategories, message];
}

class MarketCategoryDetailFailed extends MarketCategoryDetailState {
  final String error;
  const MarketCategoryDetailFailed({required this.error});
  @override
  List<Object?> get props => [error];
}
