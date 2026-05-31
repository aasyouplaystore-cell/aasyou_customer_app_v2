import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class FilterCategoryEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchFilterCategories extends FilterCategoryEvent {
  final BuildContext context;
  final List<int> categoryIds;
  FetchFilterCategories({required this.context, required this.categoryIds});
  @override
  // TODO: implement props
  List<Object?> get props => [context, categoryIds];
}

class FetchMoreFilterCategories extends FilterCategoryEvent {}