part of 'brands_bloc.dart';

sealed class BrandsEvent extends Equatable {
  const BrandsEvent();
}

class FetchBrands extends BrandsEvent{
  final String categorySlug;
  final String? brandsIds;
  const FetchBrands({required this.categorySlug, this.brandsIds});
  @override
  List<Object?> get props => [categorySlug, brandsIds];
}