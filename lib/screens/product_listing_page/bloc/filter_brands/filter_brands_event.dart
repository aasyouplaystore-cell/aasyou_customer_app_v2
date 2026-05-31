part of 'filter_brands_bloc.dart';

class FilterBrandsEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchFilterBrands extends FilterBrandsEvent{
  final String categorySlug;
  final List<int>? brandsIds;
  FetchFilterBrands({required this.categorySlug, this.brandsIds});
  @override
  List<Object?> get props => [categorySlug, brandsIds];
}