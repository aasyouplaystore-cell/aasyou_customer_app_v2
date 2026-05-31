import 'package:equatable/equatable.dart';
import 'package:aasyou/screens/home_page/model/category_model.dart';

abstract class FilterCategoryState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FilterCategoryInitial extends FilterCategoryState {}

class FilterCategoryLoading extends FilterCategoryState {}

class FilterCategoryLoaded extends FilterCategoryState {
  final List<CategoryData> categoryData;
  final String message;
  FilterCategoryLoaded({
    required this.message,
    required this.categoryData
  });

  @override
  // TODO: implement props
  List<Object?> get props => [message, categoryData];
}

class FilterCategoryFailed extends FilterCategoryState {
  final String error;
  FilterCategoryFailed({required this.error});

  @override
  // TODO: implement props
  List<Object?> get props => [error];
}