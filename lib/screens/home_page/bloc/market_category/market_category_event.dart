import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class HomeMarketCategoriesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchHomeMarketCategories extends HomeMarketCategoriesEvent {
  final BuildContext? context;
  FetchHomeMarketCategories({this.context});
  @override
  List<Object?> get props => [context];
}

class FetchMoreHomeMarketCategories extends HomeMarketCategoriesEvent {}
