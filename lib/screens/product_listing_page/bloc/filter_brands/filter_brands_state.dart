part of 'filter_brands_bloc.dart';

abstract class FilterBrandsState extends Equatable {
  const FilterBrandsState();
}

class FilterBrandsInitial extends FilterBrandsState {
  @override
  List<Object> get props => [];
}

class FilterBrandsLoading extends FilterBrandsState {
  @override
  List<Object> get props => [];
}

class FilterBrandsLoaded extends FilterBrandsState {
  final List<BrandData> brandsData;
  final String message;
  const FilterBrandsLoaded({required this.brandsData, required this.message});
  @override
  List<Object> get props => [];
}

class FilterBrandsFailed extends FilterBrandsState {
  final String error;
  const FilterBrandsFailed({required this.error});
  @override
  List<Object> get props => [error];
}
