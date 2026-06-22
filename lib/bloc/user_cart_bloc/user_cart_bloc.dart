import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_state.dart';

import '../../config/global.dart';
import '../../model/user_cart_model/cart_sync_action.dart';
import '../../screens/cart_page/bloc/get_user_cart/get_user_cart_bloc.dart';
import '../../services/user_cart/user_cart_local.dart';
import '../../services/user_cart/user_cart_remote.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartLocalRepository localRepo;
  final CartRemoteRepository remoteRepo;

  Timer? _debounce;

  CartBloc(this.localRepo, this.remoteRepo) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartQty>(_onUpdateQty);
    on<UpdateCartItemAddons>(_onUpdateCartItemAddons);
    on<RemoveFromCart>(_onRemoveItem);
    on<RemoveLocally>(_onRemoveLocally);
    on<ClearCart>(_onClearCart);
    on<SyncLocalCart>(_onSyncLocalCart);
    on<AddMultipleToCart>(_onAddMultipleToCart);
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    emit(CartLoaded(localRepo.getAllItems()));
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final bool isLoggedIn = Global.userData != null && Global.token!.isNotEmpty;

    if (isLoggedIn) {
      // Normal behavior: mark for sync
      localRepo.addItem(event.item); // this sets syncAction.add
      _debouncedSync(
        context: event.context,
        addressId: event.addressId,
        promoCode: event.promoCode,
        rushDelivery: event.rushDelivery,
        useWallet: event.useWallet,
        isFromCartPage: event.isFromCartPage,
        replaceQty: event.replaceQty
      );
    } else {
      // Guest mode: add locally but DO NOT mark for sync
      localRepo.addItemGuest(event.item); // New method → see below
      // Do NOT call _debouncedSync
    }

    emit(CartLoaded(localRepo.getAllItems()));
  }

  void _onAddMultipleToCart(AddMultipleToCart event, Emitter<CartState> emit) {
    final bool isLoggedIn = Global.userData != null && Global.token!.isNotEmpty;

    for (final item in event.items) {
      if (isLoggedIn) {
        localRepo.addItem(item);
      } else {
        localRepo.addItemGuest(item);
      }
    }

    if (isLoggedIn && event.items.isNotEmpty) {
      _debouncedSync(
        context: event.context,
        addressId: event.addressId,
        promoCode: event.promoCode,
        rushDelivery: event.rushDelivery,
        useWallet: event.useWallet,
        isFromCartPage: event.isFromCartPage,
        replaceQty: event.replaceQty
      );
    }

    emit(CartLoaded(localRepo.getAllItems()));
  }

  void _onUpdateQty(UpdateCartQty event, Emitter<CartState> emit) {
    log('Update Quantity');
    final bool isLoggedIn = Global.userData != null;

    if (isLoggedIn) {
      // Normal logged-in flow
      localRepo.updateQuantity(event.cartKey, event.quantity);
      _debouncedSync(
        context: event.context,
        addressId: event.addressId,
        promoCode: event.promoCode,
        rushDelivery: event.rushDelivery,
        useWallet: event.useWallet,
        isFromCartPage: event.isFromCartPage,
        replaceQty: event.replaceQty
      );
    } else {
      // Guest mode: update locally only
      localRepo.updateQuantityGuest(event.cartKey, event.quantity);
      // No _debouncedSync
    }

    emit(CartLoaded(localRepo.getAllItems()));

    // // Just update quantity - it will automatically set the correct syncAction
  }

  void _onUpdateCartItemAddons(
      UpdateCartItemAddons event, Emitter<CartState> emit) {

    final bool isLoggedIn = Global.userData != null && Global.token!.isNotEmpty;

    if (isLoggedIn) {
      localRepo.updateAddons(
        event.cartKey,
        event.addons,
        quantity: event.quantity,
      );
      _debouncedSync(
        context: event.context,
        addressId: event.addressId,
        promoCode: event.promoCode,
        rushDelivery: event.rushDelivery,
        useWallet: event.useWallet,
        isFromCartPage: event.isFromCartPage,
        replaceQty: event.replaceQty,
      );
    } else {
      // Guest: mutate locally, no server sync queued.
      localRepo.updateAddonsGuest(
        event.cartKey,
        event.addons,
        quantity: event.quantity,
      );
    }

    emit(CartLoaded(localRepo.getAllItems()));
  }

  void _onRemoveItem(RemoveFromCart event, Emitter<CartState> emit) {

    final bool isLoggedIn = Global.userData != null && Global.token!.isNotEmpty;

    if (isLoggedIn) {
      // Normal behavior: mark for sync
      localRepo.markForDelete(event.cartKey); // this sets syncAction.add
      _debouncedSync(
        context: event.context,
        addressId: event.addressId,
        promoCode: event.promoCode,
        rushDelivery: event.rushDelivery,
        useWallet: event.useWallet,
        isFromCartPage: event.isFromCartPage,
        replaceQty: event.replaceQty
      );
    } else {
      // Guest mode: add locally but DO NOT mark for sync
      localRepo.removeItemGuest(event.cartKey); // New method → see below
      // Do NOT call _debouncedSync
    }

    emit(CartLoaded(localRepo.getAllItems()));

    // localRepo.markForDelete(event.cartKey);
  }

  void _onRemoveLocally(RemoveLocally event, Emitter<CartState> emit) {
    localRepo.deleteLocally(event.cartKey);
    emit(CartLoaded(localRepo.getAllItems()));
    _debouncedSync(
      context: event.context,
    );
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    localRepo.clearLocalCart();
    emit(CartLoaded(const []));
    _debouncedSync(context: event.context);
  }

  void _debouncedSync({
    required BuildContext context,
    int? addressId,
    String? promoCode,
    bool? rushDelivery,
    bool? useWallet,
    bool? isFromCartPage,
    bool? replaceQty
  }) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      add(SyncLocalCart(
        context: context,
        addressId: addressId,
        promoCode: promoCode,
        rushDelivery: rushDelivery,
        useWallet: useWallet,
        isFromCartPage: isFromCartPage,
        replaceQty: replaceQty
      ));
    });
  }

  Future<void> _onSyncLocalCart(
    SyncLocalCart event,
    Emitter<CartState> emit,
  ) async {
    final pendingItems = localRepo.getPendingSyncItems();

    if (pendingItems.isEmpty) {
      return;
    }


    for (final item in pendingItems) {
      try {

        switch (item.syncAction) {
          case CartSyncAction.add:
            final List<Map<String, int>>? addonsPayload = item.addons.isEmpty
                ? null
                : item.addons.map((a) => a.toPayloadJson()).toList();
            final res = await remoteRepo.addItemToCart(
              productVariantId: int.parse(item.variantId),
              storeId: int.parse(item.vendorId),
              quantity: item.quantity,
              replaceQty: event.replaceQty ?? false,
              addons: addonsPayload,
            );
            if (res['success'] == true && res['data'] != null) {
              final itemsList = res['data']['items'] as List<dynamic>?;

              if (itemsList != null) {
                final addedServerItem = itemsList.firstWhere(
                  (serverItem) =>
                      serverItem['product_variant_id'].toString() ==
                          item.variantId &&
                      serverItem['store_id'].toString() == item.vendorId,
                  orElse: () => null,
                );

                if (addedServerItem != null) {
                  final serverCartItemId = addedServerItem['id'] as int;

                  localRepo.markSynced(
                    item.cartKey,
                    serverCartItemId: serverCartItemId,
                  );

                } else {
                }
              }
            } else {
              final errorMessage =
                  res['message'] as String? ?? 'Failed to add item to cart';

              localRepo.deleteLocally(item.cartKey);
              // ← THIS LINE MUST BE EXACTLY LIKE THIS
              emit(CartLoaded(localRepo.getAllItems(),
                  errorMessage: errorMessage));
              return;
            }

            break;

          case CartSyncAction.update:
            // ALWAYS get the absolute latest item from Hive
            final freshItem = localRepo.getItemByKey(item.cartKey);
            log('OFIEFBN');
            if (freshItem == null) {
              break;
            }

            if (freshItem.serverCartItemId == null) {
              break;
            }

            final List<Map<String, int>> freshAddonsPayload =
                freshItem.addons.map((a) => a.toPayloadJson()).toList();


            try {
              await remoteRepo.updateItemQuantity(
                cartItemId: freshItem.serverCartItemId!,
                quantity: freshItem.quantity,
                addons: freshAddonsPayload,
              );

              localRepo.markSynced(item.cartKey);
            } catch (e) {
              debugPrint('❌ UPDATE API failed → $e');
            }
            break;

          case CartSyncAction.delete:

            if (item.serverCartItemId != null) {
              try {
                await remoteRepo.removeItemFromCart(
                  cartItemId: item.serverCartItemId!,
                );
              } catch (e) {
                debugPrint('❌ DELETE API failed → $e');
                // Still remove locally even if API fails (optional: you can retry instead)
              }
            }

            // Remove from local storage after server sync
            localRepo.removeLocal(item.cartKey);
            break;

          case CartSyncAction.none:
            break;
        }
      } catch (e, stackTrace) {
        debugPrint('❌ SYNC FAILED → ${item.cartKey} → $e');
        debugPrint('Stack trace: ${stackTrace.toString()}');
        // Continue with other items instead of returning
        continue;
      }
    }

    emit(CartLoaded(localRepo.getAllItems()));

    if (event.isFromCartPage == true) {
      if (event.context.mounted) {
        event.context.read<GetUserCartBloc>().add(FetchUserCart(
              addressId: event.addressId,
              rushDelivery: event.rushDelivery,
              useWallet: event.useWallet,
              promoCode: event.promoCode,
              silent: true,
            ));
      }
    } else {
      if (event.context.mounted) {
        event.context.read<GetUserCartBloc>().add(FetchUserCart(silent: true));
      }
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
