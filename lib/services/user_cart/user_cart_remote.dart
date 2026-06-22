import 'package:aasyou/config/api_routes.dart';

import '../../config/helper.dart';

class CartRemoteRepository {
  Future<Map<String, dynamic>> addItemToCart({
    required int productVariantId,
    required int storeId,
    required int quantity,
    required bool replaceQty,
    List<Map<String, int>>? addons,
  }) async {

    final Map<String, dynamic> body = {
      'product_variant_id': productVariantId,
      'store_id': storeId,
      'quantity': quantity,
      'replace_quantity': replaceQty,
    };

    if (addons != null && addons.isNotEmpty) {
      body['addons'] = addons;
    }

    final response = await AppHelpers.apiBaseHelper.postAPICall(
      ApiRoutes.addToCartApi,
      body,
    );

    return response.data;
  }

  Future<void> updateItemQuantity({
    required int cartItemId,
    required int quantity,
    List<Map<String, int>>? addons,
  }) async {

    final Map<String, dynamic> body = {'quantity': quantity};

    if (addons != null) {
      body['addons'] = addons;
    }

    await AppHelpers.apiBaseHelper.postAPICall(
      ApiRoutes.removeItemFromCartApi + cartItemId.toString(),
      body,
    );
  }

  Future<void> removeItemFromCart({
    required int cartItemId,
  }) async {

    await AppHelpers.apiBaseHelper.deleteAPICall(
      ApiRoutes.removeItemFromCartApi + cartItemId.toString(),
      {},
    );
  }
}
