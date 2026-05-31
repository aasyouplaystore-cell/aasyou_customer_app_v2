import 'package:equatable/equatable.dart';

abstract class MarketCategoryDetailEvent extends Equatable {
  const MarketCategoryDetailEvent();
  @override
  List<Object?> get props => [];
}

class FetchMarketCategoryDetail extends MarketCategoryDetailEvent {
  final String slug;
  const FetchMarketCategoryDetail({required this.slug});
  @override
  List<Object?> get props => [slug];
}
