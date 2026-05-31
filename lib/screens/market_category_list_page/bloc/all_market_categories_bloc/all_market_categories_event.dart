import 'package:equatable/equatable.dart';

abstract class AllMarketCategoriesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAllMarketCategories extends AllMarketCategoriesEvent {}

class FetchMoreAllMarketCategories extends AllMarketCategoriesEvent {}
