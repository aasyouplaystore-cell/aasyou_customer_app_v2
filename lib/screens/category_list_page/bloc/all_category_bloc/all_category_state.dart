import 'package:equatable/equatable.dart';
import '../../../home_page/model/category_model.dart';

abstract class AllCategoriesState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AllCategoriesInitial extends AllCategoriesState {}

class AllCategoriesLoading extends AllCategoriesState {}

class AllCategoriesLoaded extends AllCategoriesState {
  final List<CategoryData> categoryData;
  final String message;
  final bool isLoadingMore;
  AllCategoriesLoaded({
    required this.message,
    required this.categoryData,
    this.isLoadingMore = false,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [message, categoryData, isLoadingMore];
}

class AllCategoriesFailed extends AllCategoriesState {
  final String error;
  AllCategoriesFailed({required this.error});

  @override
  // TODO: implement props
  List<Object?> get props => [error];
}