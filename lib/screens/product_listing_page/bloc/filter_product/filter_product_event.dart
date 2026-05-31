import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../model/product_listing_type.dart';

abstract class FilterProductEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchFilterData extends FilterProductEvent {
  final BuildContext context;
  final List<String>? categorySlugs;
  final List<String>? brandSlugs;
  final List<int>? attributeIds;
  final ProductListingType? filterType;
  final String? value;

  FetchFilterData({required this.context, this.categorySlugs, this.brandSlugs, this.attributeIds, this.filterType ,this.value});
  @override
  // TODO: implement props
  List<Object?> get props => [context, categorySlugs, brandSlugs, attributeIds, filterType, value];
}

class FetchMoreFilterData extends FilterProductEvent {}