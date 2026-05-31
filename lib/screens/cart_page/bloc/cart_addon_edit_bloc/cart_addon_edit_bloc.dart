import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/cart_addon_edit_bloc/cart_addon_edit_event.dart';
import 'package:aasyou/screens/cart_page/bloc/cart_addon_edit_bloc/cart_addon_edit_state.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/screens/product_detail_page/repo/product_detail_repo.dart';

/// Fetches the full product detail for a single cart row on demand.
class CartAddonEditBloc extends Bloc<CartAddonEditEvent, CartAddonEditState> {
  final ProductDetailRepository repository;

  CartAddonEditBloc({ProductDetailRepository? repository})
      : repository = repository ?? ProductDetailRepository(),
        super(const CartAddonEditInitial()) {
    on<FetchCartAddonCatalog>(_onFetchCartAddonCatalog);
  }

  Future<void> _onFetchCartAddonCatalog(
    FetchCartAddonCatalog event,
    Emitter<CartAddonEditState> emit,
  ) async {
    emit(const CartAddonEditLoading());
    try {
      final response =
          await repository.fetchProductDetail(productSlug: event.productSlug);
      final productDetailModel = ProductDetailModel.fromJson(response);

      if (productDetailModel.success != true ||
          productDetailModel.data == null) {
        emit(CartAddonEditFailed(
          error: productDetailModel.message.isEmpty
              ? 'Failed to load product details'
              : productDetailModel.message,
        ));
        return;
      }

      emit(CartAddonEditLoaded(product: productDetailModel.data!));
    } catch (e) {
      emit(CartAddonEditFailed(error: e.toString()));
    }
  }
}
