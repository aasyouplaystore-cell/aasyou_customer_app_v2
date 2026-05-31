import 'package:equatable/equatable.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';

abstract class CartAddonEditState extends Equatable {
  const CartAddonEditState();

  @override
  List<Object?> get props => [];
}

class CartAddonEditInitial extends CartAddonEditState {
  const CartAddonEditInitial();
}

class CartAddonEditLoading extends CartAddonEditState {
  const CartAddonEditLoading();
}

/// Catalog resolved for the cart row being edited.
class CartAddonEditLoaded extends CartAddonEditState {
  final ProductData product;

  const CartAddonEditLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class CartAddonEditFailed extends CartAddonEditState {
  final String error;

  const CartAddonEditFailed({required this.error});

  @override
  List<Object?> get props => [error];
}
