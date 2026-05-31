import 'package:equatable/equatable.dart';
import 'package:aasyou/screens/product_listing_page/model/filter_product_model.dart';

abstract class FilterProductState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FilterProductInitial extends FilterProductState {}

class FilterProductLoading extends FilterProductState {}

class FilterProductLoaded extends FilterProductState {
  final List<FilterCategories> filterCategories;
  final List<FilterBrands> filterBrands;
  final List<FilterAttributesValues> filterAttributesValues;
  FilterProductLoaded({
    required this.filterCategories,
    required this.filterBrands,
    required this.filterAttributesValues,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [filterCategories, filterBrands, filterAttributesValues];
}

class FilterProductFailed extends FilterProductState {
  final String error;
  FilterProductFailed({required this.error});

  @override
  // TODO: implement props
  List<Object?> get props => [error];
}