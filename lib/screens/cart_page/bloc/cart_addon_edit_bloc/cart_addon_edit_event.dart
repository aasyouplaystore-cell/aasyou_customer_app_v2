import 'package:equatable/equatable.dart';

abstract class CartAddonEditEvent extends Equatable {
  const CartAddonEditEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch the full product detail so the edit sheet can show every variant.
class FetchCartAddonCatalog extends CartAddonEditEvent {
  final String productSlug;

  const FetchCartAddonCatalog({required this.productSlug});

  @override
  List<Object?> get props => [productSlug];
}
