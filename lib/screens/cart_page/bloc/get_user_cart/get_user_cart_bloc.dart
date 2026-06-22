import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/screens/cart_page/model/get_cart_model.dart';
import 'package:aasyou/screens/cart_page/repo/cart_repository.dart';
import '../../../../bloc/user_cart_bloc/user_cart_event.dart';
import '../../../../bloc/user_cart_bloc/user_cart_state.dart';
import '../../../../model/user_cart_model/cart_addon.dart';
import '../../../../model/user_cart_model/user_cart.dart';
import '../../../../services/user_cart/user_cart_local.dart';
import '../../../../services/user_cart/user_cart_remote.dart';
import '../../widgets/cart_product_item.dart';

part 'get_user_cart_state.dart';
part 'get_user_cart_event.dart';

class GetUserCartBloc extends Bloc<GetUserCartEvent, GetUserCartState> {
  GetUserCartBloc(this.cartBloc) : super(GetUserCartInitial()) {
    on<FetchUserCart>(_onFetchUserCart);
    on<RefreshUserCart>(_onRefreshUserCart);
    on<SyncCart>(_onSyncCart);
    on<SyncServerCartToLocal>(_onSyncServerCartToLocal);
    on<ApplyLocalCartPatch>(_onApplyLocalCartPatch);

    // Listen to CartBloc for optimistic UI patches.
    _cartBlocSubscription = cartBloc.stream.listen((cartState) {
      if (cartState is CartLoaded) {
        add(ApplyLocalCartPatch(localItems: cartState.items));
      }
    });
  }

  final CartRepository repository = CartRepository();
  final localRepo = CartLocalRepository(Hive.box<UserCart>('cartBox'));
  final CartBloc cartBloc;
  final CartBloc localCartBloc = CartBloc(CartLocalRepository(Hive.box<UserCart>('cartBox')),
      CartRemoteRepository());
  List<CartModel> cartData = [];
  bool isUpdated = false;
  List<String> productSlug = [];
  int totalCartItems = 0;
  StreamSubscription<CartState>? _cartBlocSubscription;

  Future<void> _onFetchUserCart(FetchUserCart event, Emitter<GetUserCartState> emit) async {
    if (!event.silent) {
      emit(GetUserCartLoading());
    }
    try{
      final getCartData = await repository.getCartItems(
        addressId: event.addressId,
        promoCode: event.promoCode,
        rushDelivery: event.rushDelivery,
        useWallet: event.useWallet
      );

      cartData = getCartData;
      if (cartData.first.data == null) {
        // Server says cart is empty or failed
        final message = cartData.isNotEmpty ? cartData.first.message ?? '' : '';

        if (message.toLowerCase().contains('empty') ||
            (getCartData.first.data?.items.isEmpty ?? true)) {


          // CLEAR LOCAL HIVE CART
          localRepo.clearLocalCart();
          Future.delayed((const Duration(milliseconds: 500)),(){
            cartBloc.add(LoadCart());
          });
          // Reload CartBloc to reflect empty state

        }

        // Emit loaded state even if empty
        emit(GetUserCartLoaded(
          cartData: cartData,
          message: message,
        ));

        return;
      }

      if(getCartData.first.success == true) {
        final data = cartData.isNotEmpty ? cartData.first.data : null;

        if(data != null && data.items.isNotEmpty) {
          productSlug = data.items
              .map((item) => item.product?.slug ?? '')
              .toList();
        }

        if(event.isRefresh == false){
          // 🔄 SYNC SERVER CART TO LOCAL STORAGE
          if (data != null && data.items.isNotEmpty) {
            final serverItems = data.items;


            // Convert to sync format
            final serverItemsList = serverItems.map((item) {
              final product = item.product;
              final variant = item.variant;
              final mapped = {
                'id': item.id,
                'product_id': item.product?.id,
                'product_variant_id': item.productVariantId,
                'variant_name': item.variant?.title ?? '',
                'store_id': item.storeId,
                'name': product?.name ?? variant?.title ?? '',
                'image': product?.image ?? variant?.image ?? '',
                'price': variant?.price ?? 0,
                'special_price': variant?.specialPrice ?? 0,
                'quantity': item.quantity,
                'stock': variant?.stock ?? 0,
                'cart_item_id': item.id ?? 0,
                'addons': item.addons
                    .map((a) => {
                          'addon_group_id': a.addonGroupId ?? 0,
                          'addon_item_id': a.addonItemId ?? 0,
                          'title': a.item?.title ?? '',
                          'price': a.price ?? 0,
                        })
                    .toList(),
              };
              return mapped;
            }).toList();

            // Wait a bit to ensure Hive is fully initialized
            await Future.delayed(const Duration(milliseconds: 150));

            try {
              // Sync to local storage
              localRepo.syncServerCartToLocal(serverItemsList);

              // CRITICAL: Reload CartBloc to show synced items
              await Future.delayed(const Duration(milliseconds: 150));
              cartBloc.add(LoadCart());
            } catch (syncError, stackTrace) {
              debugPrint('❌ Sync failed: $syncError');
              debugPrint('Stack: $stackTrace');
            }

            // Update product slugs
            productSlug = serverItems
                .map((item) => item.product?.slug ?? '')
                .toList();
          }
          else {
          }
        }

        totalCartItems = data?.itemsCount ?? 0;
        emit(GetUserCartLoaded(
          cartData: cartData,
          message: cartData.first.message ?? ''
        ));

        localCartBloc.add(LoadCart());
      } else {
        emit(GetUserCartLoaded(
          cartData: cartData,
          message: getCartData.first.message ?? ''
        ));
      }
    }catch (e) {
      emit(GetUserCartFailed(error: e.toString()));
    }
  }

  Future<void> _onRefreshUserCart(RefreshUserCart event, Emitter<GetUserCartState> emit) async {
    try{
      emit(GetUserCartInitial());
      Future.microtask((){
        add(FetchUserCart(
          addressId: event.addressId,
          promoCode: event.promoCode,
          rushDelivery: event.rushDelivery,
          useWallet: event.useWallet,
          isRefresh: true
        ));
      });
    }catch(e) {
      emit(GetUserCartFailed(error: e.toString()));
    }
  }

  Future<void> _onSyncCart(SyncCart event, Emitter<GetUserCartState> emit) async {
    emit(UserCartInitialLoading());
    try{
      final response = await repository.syncCart(items: localRepo.createSyncPayload());

      if(response['success'] == true){
        add(FetchUserCart());
      } else {
        emit(GetUserCartFailed(error: response['message'].toString()));
      }
    }catch(e) {
      emit(GetUserCartFailed(error: e.toString()));
    }
  }

  Future<void> _onSyncServerCartToLocal(
      SyncServerCartToLocal event,
      Emitter<GetUserCartState> emit,
      ) async {

    if (event.serverItems.isEmpty) {
      return;
    }

    try {
      localRepo.syncServerCartToLocal(event.serverItems);

      // Reload CartBloc
      cartBloc.add(LoadCart());
    } catch (e) {
      debugPrint('❌ Manual sync failed: $e');
    }
  }

  // ─── Optimistic UI: patch server CartModel with local Hive state ───

  void _onApplyLocalCartPatch(
    ApplyLocalCartPatch event,
    Emitter<GetUserCartState> emit,
  ) {
    // Only patch when we already have server data to patch against.
    final data = cartData.isEmpty ? null : cartData.first.data;
    if (data == null) return;

    final serverItems = data.items;
    if (serverItems.isEmpty) return;

    final localItems = event.localItems;

    // Build a lookup by (productId, variantId) for fallback matching.
    final localByPV = <String, UserCart>{};
    for (final l in localItems) {
      localByPV['${l.productId}_${l.variantId}'] = l;
    }

    bool changed = false;
    final patchedItems = <CartItem>[];

    for (final serverItem in serverItems) {
      // Try to find a matching local item.
      UserCart? localMatch;
      for (final l in localItems) {
        if (l.serverCartItemId != null &&
            l.serverCartItemId == serverItem.id) {
          localMatch = l;
          break;
        }
      }

      // Fallback: match by (productId, variantId).
      localMatch ??= localByPV[
          '${serverItem.productId}_${serverItem.productVariantId}'];

      if (localMatch == null) {
        // No local match — keep server item unchanged.
        patchedItems.add(serverItem);
        continue;
      }

      // Compare qty and addons to decide if patch is needed.
      final qtyChanged = localMatch.quantity != serverItem.quantity;
      final addonsChanged =
          !_addonsEqual(localMatch.addons, serverItem.addons);

      if (!qtyChanged && !addonsChanged) {
        patchedItems.add(serverItem);
        continue;
      }

      changed = true;

      // Build patched addons list.
      final patchedAddons = _patchAddons(localMatch.addons, serverItem.addons);

      patchedItems.add(CartItem(
        id: serverItem.id,
        cartId: serverItem.cartId,
        productId: serverItem.productId,
        productVariantId: serverItem.productVariantId,
        storeId: serverItem.storeId,
        quantity: localMatch.quantity,
        saveForLater: serverItem.saveForLater,
        product: serverItem.product,
        variant: serverItem.variant,
        store: serverItem.store,
        addons: patchedAddons,
        createdAt: serverItem.createdAt,
        updatedAt: serverItem.updatedAt,
      ));
    }

    if (!changed) return;

    // Recompute counts.
    int newItemsCount = patchedItems.length;
    int newTotalQty = 0;
    for (final item in patchedItems) {
      newTotalQty += item.quantity ?? 0;
    }

    final oldData = cartData.first.data!;
    final patchedData = CartData(
      id: oldData.id,
      uuid: oldData.uuid,
      userId: oldData.userId,
      itemsCount: newItemsCount,
      totalQuantity: newTotalQty,
      items: patchedItems,
      paymentSummary: oldData.paymentSummary, // stale until server GET
      removedItems: oldData.removedItems,
      removedCount: oldData.removedCount,
      deliveryZone: oldData.deliveryZone,
      createdAt: oldData.createdAt,
      updatedAt: oldData.updatedAt,
    );

    cartData = [
      CartModel(
        success: cartData.first.success,
        message: cartData.first.message,
        data: patchedData,
      ),
    ];

    totalCartItems = newItemsCount;


    emit(GetUserCartLoaded(
      cartData: cartData,
      message: cartData.first.message ?? '',
    ));
  }

  /// Compare local [CartAddon] list with server [CartItemAddon] list by.
  bool _addonsEqual(List<CartAddon> local, List<CartItemAddon> server) {
    if (local.length != server.length) return false;
    final localIds = local.map((a) => a.addonItemId).toSet();
    final serverIds = server.map((a) => a.addonItemId).toSet();
    return localIds.length == serverIds.length &&
        localIds.containsAll(serverIds);
  }

  /// Build a patched [CartItemAddon] list.
  List<CartItemAddon> _patchAddons(
    List<CartAddon> local,
    List<CartItemAddon> serverAddons,
  ) {
    final serverMap = <int, CartItemAddon>{};
    for (final s in serverAddons) {
      if (s.addonItemId != null) serverMap[s.addonItemId!] = s;
    }

    return local.map((l) {
      final existing = serverMap[l.addonItemId];
      if (existing != null) return existing;

      // Fabricate a lightweight server-shaped object.
      return CartItemAddon(
        addonGroupId: l.addonGroupId,
        addonItemId: l.addonItemId,
        price: l.price,
        item: CartItemAddonItem(
          id: l.addonItemId,
          title: l.title,
        ),
      );
    }).toList();
  }

  @override
  Future<void> close() {
    _cartBlocSubscription?.cancel();
    return super.close();
  }
}