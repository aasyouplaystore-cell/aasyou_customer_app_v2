import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/bloc/settings_bloc/settings_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/config/settings_data_instance.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/config/payment_config.dart';
import 'package:aasyou/screens/cart_page/bloc/clear_cart/clear_cart_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/clear_cart/clear_cart_event.dart';
import 'package:aasyou/screens/cart_page/bloc/remove_item_from_cart/remove_item_from_cart_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/remove_item_from_cart/remove_item_from_cart_event.dart';
import 'package:aasyou/screens/cart_page/bloc/update_item_quantity/update_item_quantity_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/update_item_quantity/update_item_quantity_event.dart';
import 'package:aasyou/screens/cart_page/bloc/update_item_quantity/update_item_quantity_state.dart';
import 'package:aasyou/screens/cart_page/bloc/remove_item_from_cart/remove_item_from_cart_state.dart';
import 'package:aasyou/screens/cart_page/widgets/bill_summary_widget.dart';
import 'package:aasyou/screens/cart_page/widgets/delivery_address_widget.dart';
import 'package:aasyou/screens/cart_page/widgets/address_selection_bottom_sheet.dart';
import 'package:aasyou/screens/product_detail_page/widgets/product_detail_shimmer.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_refresh_indicator.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import '../../../bloc/user_cart_bloc/user_cart_state.dart';
import '../../../config/global.dart';
import '../../../config/helper.dart';
import '../../../services/address/selected_address_hive.dart';
import '../../../services/user_cart/cart_validation.dart';
import '../../../utils/widgets/whole_page_progress.dart';
import '../../../l10n/app_localizations.dart';
import '../../my_orders/bloc/create_order/create_order_bloc.dart';
import '../../payment_options/bloc/payment_bloc.dart';
import '../../payment_options/bloc/payment_event.dart';
import '../../payment_options/bloc/payment_state.dart';
import '../../payment_options/widgets/webview_payment.dart';
import '../../product_detail_page/bloc/similar_product_bloc/similar_product_bloc.dart';
import '../../address_list_page/model/get_address_list_model.dart';
import '../../address_list_page/bloc/get_address_list_bloc/get_address_list_bloc.dart';
import '../../wallet_page/bloc/user_wallet/user_wallet_bloc.dart';
import '../../save_for_later_page/bloc/save_for_later_bloc/save_for_later_bloc.dart';
import '../../save_for_later_page/bloc/save_for_later_bloc/save_for_later_state.dart';
import '../../../router/app_routes.dart';
import '../bloc/attachment/attachment_bloc.dart';
import '../bloc/cart_ui_bloc/cart_ui_bloc.dart';
import '../bloc/cart_ui_bloc/cart_ui_event.dart';
import '../bloc/cart_ui_bloc/cart_ui_state.dart';
import '../bloc/get_user_cart/get_user_cart_bloc.dart';
import '../bloc/promo_code/promo_code_bloc.dart';
import '../bloc/promo_code/promo_code_event.dart';
import '../bloc/promo_code/promo_code_state.dart';
import '../bloc/clear_cart/clear_cart_state.dart';
import '../model/get_cart_model.dart';
import '../widgets/cart_product_item.dart';
import '../widgets/delivery_type_widget.dart';
import '../widgets/fulfillment_toggle_widget.dart';
import '../widgets/order_note_widget.dart';
import '../widgets/removed_items_widget.dart';
import '../widgets/wallet_usage_widget.dart';
import '../widgets/you_might_also_like_product_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  AddressListData? selectedAddress;
  double totalAmount = 0.0;
  String? selectedPaymentMethod;
  dynamic selectedPaymentMethodType;
  bool isCartLoading = true;
  bool _isInitialFetch = true;
  bool isClearingCart = false;
  bool isWholePageProgress = false;
  DeliveryType selectedDeliveryType = DeliveryType.regular;
  int? cartId;
  late bool _userWantsWallet = false;
  List<CartModel> stateData = [];
  int? deliveryZoneId;
  int? previousDeliveryZoneId;
  String? promoCode;
  String orderNote = '';

  @override
  void initState() {
    super.initState();
    isCartLoading = true;
    _isInitialFetch = true;
    _userWantsWallet = false;
    // context.read<GetUserCartBloc>().add(SyncCart());
    context.read<GetUserCartBloc>().add(FetchUserCart());
    context.read<SettingsBloc>().add(FetchSettingsData(context: context));
    context.read<SimilarProductBloc>().add(FetchSimilarProduct(
        excludeProductSlug: context.read<GetUserCartBloc>().productSlug)
    );
    context.read<PromoCodeBloc>().add(RemovePromoCode());
    context.read<UserWalletBloc>().add(FetchUserWallet());
    context.read<AttachmentBloc>().add(ClearAllAttachments());
  }

  bool get canUseWallet {
    final settingsState = context.read<SettingsBloc>().state;
    return settingsState is SettingsLoaded &&
        (SettingsData.instance.payment?.wallet ?? false);
  }
  bool get effectiveUseWallet => canUseWallet && _userWantsWallet;

  void _refreshCart({bool resetWalletPreference = false}) {
    if (resetWalletPreference) {
      _userWantsWallet = false;
    }

    context.read<GetUserCartBloc>().add(
      FetchUserCart(
        addressId: selectedAddress?.id,
        rushDelivery: selectedDeliveryType == DeliveryType.rush,
        useWallet: effectiveUseWallet,
        promoCode: promoCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (BuildContext context, PaymentState state) {
        return Stack(
          children: [
            CustomScaffold(
                showViewCart: false,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                title: l10n?.cart ?? 'Cart',
                appBarActions: [
                  BlocBuilder<GetUserCartBloc, GetUserCartState>(
                    builder: (BuildContext context, GetUserCartState state) {
                      bool hasItems = true;

                      if(state is GetUserCartLoaded && state.cartData.isNotEmpty){
                        hasItems = state.cartData.first.data?.items != null;
                      }
                      if(hasItems) {
                        return Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: TextButton(
                              onPressed: () async {
                                final shouldClear = await _showClearCartConfirmDialog(context);
                                if (shouldClear) {
                                  if(context.mounted) {
                                    context.read<ClearCartBloc>().add(ClearCartRequest());
                                    context.read<CartBloc>().add(ClearCart(context: context));
                                  }
                                }
                                Future.delayed(const Duration(milliseconds: 200),(){
                                  if(context.mounted) {
                                    context.read<GetUserCartBloc>().add(FetchUserCart(
                                        addressId: selectedAddress?.id,
                                        rushDelivery: selectedDeliveryType == DeliveryType.rush,
                                        useWallet: _userWantsWallet,
                                        promoCode: promoCode
                                    ));
                                  }
                                });
                              },

                              child: Text(
                                AppLocalizations.of(context)!.clearCart,
                                style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 14
                                ),
                              )
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
                showAppBar: true,
                body: MultiBlocListener(
                  listeners: [
                    BlocListener<SettingsBloc, SettingsState>(
                      listener: (context, settingsState) {
                        log('Get Address List Bloc  $state');
                        if(settingsState is SettingsLoaded) {
                          final walletAllowed = SettingsData.instance.payment?.wallet ?? false;
                          if (!walletAllowed && _userWantsWallet) {
                            setState(() {
                              _userWantsWallet = false;
                            });

                            // Refresh cart immediately with wallet off
                            _refreshCart();
                          }
                        }
                      },
                    ),
                    BlocListener<GetAddressListBloc, GetAddressListState>(
                      listener: (context, addressState) {
                        log('Get Address List Bloc  $state');
                        // Auto-select first address when addresses are loaded
                        if (addressState is GetAddressListLoaded &&
                            selectedAddress == null &&
                            addressState.addressList.isNotEmpty) {
                          setState(() {
                            selectedAddress = addressState.addressList.first;
                            isCartLoading = true;
                          });
                          // Save selected address to Hive
                          HiveSelectedAddressHelper.setSelectedAddress(addressState.addressList.first);
                          // Update cart with selected address
                          context.read<GetUserCartBloc>().add(FetchUserCart(
                              addressId: selectedAddress?.id,
                              rushDelivery: selectedDeliveryType == DeliveryType.rush,
                              useWallet: _userWantsWallet,
                              promoCode: promoCode
                          ));
                        }
                      },
                    ),
                    BlocListener<GetUserCartBloc, GetUserCartState>(
                      listener: (context, state) {
                        log('Get User Cart Bloc  $state');
                        if(state is GetUserCartLoaded) {
                          setState(() {
                            isCartLoading = false;
                            _isInitialFetch = false;
                            // Extract deliveryZoneId from cart data
                            if(state.cartData.isNotEmpty &&
                                state.cartData.first.data?.deliveryZone != null) {
                              final newDeliveryZoneId = state.cartData.first.data?.deliveryZone!.zoneId;
                              // Only fetch addresses if deliveryZoneId changed or is first time set
                              if(newDeliveryZoneId != null && newDeliveryZoneId != previousDeliveryZoneId) {
                                deliveryZoneId = newDeliveryZoneId;
                                previousDeliveryZoneId = newDeliveryZoneId;
                                // Fetch address list with deliveryZoneId for checkout (only when zone changes)
                                context.read<GetAddressListBloc>().add(
                                    FetchUserAddressList(deliveryZoneId: deliveryZoneId)
                                );
                              } else if(newDeliveryZoneId != null) {
                                // Update deliveryZoneId but don't fetch addresses if it hasn't changed
                                deliveryZoneId = newDeliveryZoneId;
                              }
                            }
                          });
                          context.read<CartUIBloc>().add(SetWalletLoading(false));
                        }
                        else if(state is GetUserCartLoading) {
                          setState(() {
                            isCartLoading = true;
                          });
                          context.read<CartUIBloc>().add(SetWalletLoading(false));
                        }
                        else if(state is GetUserCartFailed) {
                          setState(() {
                            isCartLoading = false;
                            _isInitialFetch = false;
                          });
                          context.read<CartUIBloc>().add(SetWalletLoading(false));
                        }
                      }
                    ),
                    BlocListener<RemoveItemFromCartBloc, RemoveItemFromCartState>(
                      listener: (context, state){

                        log('Remove Item From Cart Bloc  $state');
                        if(state is RemoveItemFromCartLoading){
                          setState(() {
                            isCartLoading = true;
                          });
                        }
                        if(state is RemoveItemFromCartSuccess){
                          // Keep loading true, will be set to false when cart loads
                          context.read<GetUserCartBloc>().add(FetchUserCart(
                              addressId: selectedAddress?.id,
                              rushDelivery: selectedDeliveryType == DeliveryType.rush,
                              useWallet: _userWantsWallet,
                              promoCode: promoCode
                          ));
                        }
                        if(state is RemoveItemFromCartFailed) {
                          setState(() {
                            isCartLoading = true;
                          });
                        }
                      },
                    ),
                    BlocListener<ClearCartBloc, ClearCartState>(
                      listener: (context, state) {
                        log('Clear Cart Bloc  $state');
                        if(state is ClearCartLoading) {
                          setState(() {
                            isCartLoading = true;
                            isClearingCart = true;
                          });
                        } else if(state is ClearCartSuccess || state is ClearCartFailed) {
                          // context.read<GetUserCartBloc>().add(RefreshUserCart(
                          setState(() {
                            isCartLoading = false;
                            isClearingCart = false;
                          });
                        }
                      },
                    ),
                    BlocListener<SaveForLaterBloc, SaveForLaterState>(
                      listener: (context, state) {
                        log('Save For Later Bloc  $state');
                        if(state is SaveForLaterLoading) {
                          setState(() {
                            isCartLoading = true;
                          });
                        } else if(state is ProductSavedSuccess) {
                          // Cart will be refreshed automatically
                          setState(() {
                            isCartLoading = false;
                          });

                          ToastManager.show(
                              context: context,
                              message: '${state.productName} is saved for later'
                          );
                          context.read<GetUserCartBloc>().add(FetchUserCart(
                              addressId: selectedAddress?.id,
                              rushDelivery: selectedDeliveryType == DeliveryType.rush,
                              useWallet: _userWantsWallet,
                              promoCode: promoCode
                          ));
                        } else if(state is SaveForLaterFailed) {
                          setState(() {
                            isCartLoading = false;
                          });
                        }
                      },
                    ),
                    BlocListener<CreateOrderBloc, CreateOrderState>(
                      listener: (context, state) {
                        log('Create Order Bloc  $state');
                        if (state is CreateOrderSuccess) {

                          context.read<CartUIBloc>().add(SetWholePageProgress(true));
                          context.read<CartUIBloc>().add(SetWalletLoading(false));
                          setState(() {
                            isWholePageProgress = true;
                            isCartLoading = true;
                          });
                          if(selectedPaymentMethodType == PaymentMethodType.flutterwave) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WebViewPaymentPage(
                                  paymentUrl: state.paymentUrl!,
                                  onPaymentSuccess: () {
                                    setState(() {
                                      isWholePageProgress = false;
                                      isCartLoading = false;
                                    });
                                  },
                                  onPaymentFailure: () {
                                    setState(() {
                                      isWholePageProgress = false;
                                      isCartLoading = false;
                                    });
                                    context.read<GetUserCartBloc>().add(FetchUserCart(
                                      addressId: selectedAddress?.id,
                                      rushDelivery: selectedDeliveryType == DeliveryType.rush,
                                      useWallet: _userWantsWallet,
                                      promoCode: promoCode
                                    ));
                                  },
                                ))
                            );
                          } else {
                            final displayAddress = selectedAddress != null
                                ? formatAddressFromModel(selectedAddress!)
                                : null;

                            GoRouter.of(context).pop();
                            log('Payment successful: ${state.message}');

                            // Navigate to order success page
                            GoRouter.of(context).push(
                              AppRoutes.orderSuccess,
                              extra: {
                                'address': displayAddress,
                                'addressType': selectedAddress!.addressType,
                                'orderSlug': state.orderSlug,
                              },
                            );
                          }

                        }
                        else if (state is CreateOrderFailure) {
                          setState(() {
                            isWholePageProgress = false;
                            isCartLoading = false;
                          });
                          ToastManager.show(
                            context: context,
                            message: state.error,
                            type: ToastType.error,
                          );
                        }
                        else if (state is CreateOrderProgress) {
                          setState(() {
                            isWholePageProgress = true;
                          });
                        }
                      },
                    ),
                    // Payment BLoC Listener
                    BlocListener<PaymentBloc, PaymentState>(
                      listener: (context, state) {
                        log('Payment Bloc  $state');
                        log('Payment Success  $state');
                        if (state is PaymentSuccess) {
                          setState(() {
                            isWholePageProgress = false;
                          });
                          context.read<CartUIBloc>().add(SetWalletLoading(false));
                          _initiatePayment(
                              paymentId: state.transactionId,
                              signature: state.signature,
                              orderId: state.orderId
                          );
                        }
                        else if (state is PaymentFailure) {
                          setState(() {
                            isWholePageProgress = false;
                          });
                          context.read<CartUIBloc>().add(SetWalletLoading(false));
                          ToastManager.show(
                              context: context,
                              message: state.error,
                              type: ToastType.error
                          );
                        }
                        else if(state is PaymentLoading) {
                          setState(() {
                            isWholePageProgress = true;
                          });
                        }
                      },
                    ),
                    BlocListener<UpdateItemQuantityBloc, UpdateItemQuantityState>(
                      listener: (context, state){
                        log('Update Item Quantity Bloc  $state');
                        if(state is UpdateItemQuantityLoading){
                          setState(() {
                            isCartLoading = true;
                          });
                        }
                        if(state is UpdateItemQuantitySuccess) {
                          // Keep loading true, will be set to false when cart loads
                          context.read<GetUserCartBloc>().add(FetchUserCart(
                              addressId: selectedAddress?.id,
                              rushDelivery: selectedDeliveryType == DeliveryType.rush,
                              useWallet: _userWantsWallet,
                              promoCode: promoCode
                          ));
                        }
                        if(state is UpdateItemQuantityFailed){
                          setState(() {
                            isCartLoading = false;
                          });
                        }
                      },
                    ),
                    BlocListener<PromoCodeBloc, PromoCodeState>(
                      listener: (context, state){
                        if(state is PromoCodeRemoving || state is PromoCodeApplying || state is PromoCodeLoading){
                          setState(() {
                            isCartLoading = true;
                          });
                        }
                        if(state is PromoCodeFailed){
                          setState(() {
                            isCartLoading = false;
                          });
                          ToastManager.show(
                              context: context,
                              message: AppLocalizations.of(context)!.promoCodeAppliedOnYourCart
                          );
                        }
                        if(state is PromoCodeSelected){
                          setState(() {
                            promoCode = state.promoCode;
                            isCartLoading = false;
                          });
                          if(state.promoCode.isNotEmpty) {
                            ToastManager.show(
                                context: context,
                                message: AppLocalizations.of(context)!.promoCodeAppliedOnYourCart
                            );
                          }
                        }
                        if(state is PromoCodeRemoved){
                          setState(() {
                            promoCode = state.promoCode;
                            isCartLoading = false;
                          });
                        }
                      },
                    )
                  ],
                  child: BlocBuilder<GetUserCartBloc, GetUserCartState>(
                    builder: (BuildContext context, GetUserCartState state) {
                      if(_isInitialFetch || state is UserCartInitialLoading){
                        return const CustomCircularProgressIndicator();
                      }
                      return CustomRefreshIndicator(
                        onRefresh: () async {
                          context.read<GetUserCartBloc>().add(RefreshUserCart(
                              addressId: selectedAddress?.id,
                              rushDelivery: selectedDeliveryType == DeliveryType.rush,
                              useWallet: _userWantsWallet,
                              promoCode: promoCode
                          ));
                          context.read<SettingsBloc>().add(FetchSettingsData(context: context));
                          context.read<GetAddressListBloc>().add(FetchUserAddressList(deliveryZoneId: deliveryZoneId));
                          context.read<UserWalletBloc>().add(FetchUserWallet());
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: BlocBuilder<GetUserCartBloc, GetUserCartState>(
                            builder: (BuildContext context, GetUserCartState state) {
                              log('Get User Cart State $state');
                              log('isCartLoading $isCartLoading');
                              if(state is GetUserCartLoaded) {
                                stateData = state.cartData;
                              }
                              if (isClearingCart) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 50.h),
                                      const CustomCircularProgressIndicator(),
                                      SizedBox(height: 10.h),
                                      Text(AppLocalizations.of(context)!.clearingYourCart, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                );
                              }
                              if (stateData.isEmpty) {
                                final localCartState = context.read<CartBloc>().state;
                                bool hasLocalItems = false;
                                if (localCartState is CartLoaded) {
                                  hasLocalItems = localCartState.items.isNotEmpty;
                                }

                                if (isCartLoading) {
                                  // We have local items but server/stateData is empty => SYNCING
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 50.h),
                                        const CustomCircularProgressIndicator(),
                                        SizedBox(height: 10.h),
                                        Text(hasLocalItems ? "Syncing your cart..." : "Loading...", style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  );
                                }

                                // isCartLoading = false;
                                return _buildEmptyCartState();
                              }

                              isCartLoading = false;
                              if(stateData.first.data?.items != null) {
                                isCartLoading = false;
                                cartId = stateData.first.data?.id;
                                final cartData = stateData;
                                final billSummaryData = cartData.first.data!.paymentSummary;
                                deliveryZoneId = cartData.first.data?.deliveryZone!.zoneId;
                                totalAmount = billSummaryData?.payableAmount?.toDouble() ?? 0.0;
                                return Column(
                                  children: [
                                    RemovedItemsWidget(
                                      removedItems: cartData.first.data?.removedItems ?? [],
                                    ),
                                    CartWidget(
                                      items: cartData.first.data!.items,
                                      deliveryTime: cartData.first.data!.paymentSummary!.estimatedDeliveryTime.toString(),
                                      onQuantityChanged: _handleQuantityChanged,
                                      onRemoveItem: _handleRemoveItem,
                                      onAddMoreItems: _handleAddMoreItems,
                                      // Customization options
                                      backgroundColor: Theme.of(context).colorScheme.surface,
                                      quantityButtonColor: AppTheme.primaryColor,
                                      priceColor: Colors.black,
                                      originalPriceColor: Colors.grey[500],
                                      totalItem: cartData.first.data!.totalQuantity,
                                      addressId: selectedAddress?.id,
                                      rushDelivery: selectedDeliveryType == DeliveryType.rush,
                                      useWallet: _userWantsWallet,
                                      promoCode: promoCode
                                    ),
                                    offerAndCouponButton(),
                                    SizedBox(height: 9.h,),
                                    BlocBuilder<SimilarProductBloc, SimilarProductState>(
                                        builder: (context, state) {
                                          if(state is SimilarProductLoaded) {
                                            if(state.similarProduct.isNotEmpty) {
                                              return YouMightAlsoLikeProductWidget(
                                                  productData: state.similarProduct,
                                                  addressId: selectedAddress?.id,
                                                  rushDelivery: selectedDeliveryType == DeliveryType.rush,
                                                  useWallet: _userWantsWallet,
                                                  promoCode: promoCode,
                                                  isFromCartPage: true
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          } else if(state is SimilarProductLoading) {
                                            return productListShimmer(3);
                                          }
                                          return const SizedBox.shrink();
                                        }
                                    ),
                                    SizedBox(height: 9.h,),
                                    BlocBuilder<CartUIBloc, CartUIState>(
                                      builder: (context, uiState) {
                                        final bool isSelfPickupAvailable = _computeIsSelfPickupAvailable(stateData);
                                        final bool isSelfPickup =
                                            uiState.selectedFulfillmentMode == FulfillmentMode.selfPickup;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (isSelfPickupAvailable)
                                              FulfillmentToggleWidget(
                                                selectedMode: uiState.selectedFulfillmentMode,
                                                isSelfPickupAvailable: isSelfPickupAvailable,
                                                onModeChanged: (FulfillmentMode mode) {
                                                  context.read<CartUIBloc>().add(SetFulfillmentMode(mode));
                                                  if (mode == FulfillmentMode.selfPickup &&
                                                      selectedDeliveryType != DeliveryType.regular) {
                                                    setState(() {
                                                      selectedDeliveryType = DeliveryType.regular;
                                                    });
                                                    // Keep CartUIBloc.selectedDeliveryType in sync (single source of truth fix).
                                                    context.read<CartUIBloc>().add(SetDeliveryType(DeliveryType.regular));
                                                    _updateCartWithDeliveryType(DeliveryType.regular);
                                                  }
                                                },
                                              ),
                                            if (!isSelfPickup) ...[
                                              SizedBox(height: 9.h,),
                                              DeliveryTypeWidget(
                                                selectedDeliveryType: selectedDeliveryType,
                                                rushDeliveryCharge: billSummaryData?.rushDeliveryCharge ?? 0.0,
                                                regularDeliveryCharge: billSummaryData?.regularDeliveryCharge ?? 0.0,
                                                isRushDeliveryDisabled: billSummaryData?.isRushDeliveryAvailable == false,
                                                onDeliveryTypeChanged: (DeliveryType type) {
                                                  setState(() {
                                                    selectedDeliveryType = type;
                                                  });
                                                  context.read<CartUIBloc>().add(SetDeliveryType(type));
                                                  _updateCartWithDeliveryType(type);
                                                },
                                              ),
                                            ],
                                          ],
                                        );
                                      },
                                    ),
                                    BlocBuilder<CartUIBloc, CartUIState>(
                                      builder: (context, uiState) {
                                        return BlocBuilder<SettingsBloc, SettingsState>(
                                          builder: (context, settingsState) {
                                            final walletAllowed = settingsState is SettingsLoaded
                                                ? SettingsData.instance.payment?.wallet ?? false
                                                : false;

                                            // Defensive clamp (in case listener missed edge case)
                                            if (!walletAllowed && _userWantsWallet) {
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                if (mounted) {
                                                  setState(() {
                                                    _userWantsWallet = false;
                                                  });
                                                  _refreshCart();
                                                }
                                              });
                                            }

                                            // Hide completely when not allowed
                                            if (!walletAllowed) {
                                              return const SizedBox.shrink();
                                            }

                                            // Show toggle only when allowed
                                            return Column(
                                              children: [
                                                SizedBox(height: 9.h,),

                                                WalletUsageWidget(
                                                  isWalletEnabled: effectiveUseWallet,
                                                  isLoading: isCartLoading || uiState.isWalletLoading,
                                                  onWalletToggle: !uiState.isWalletLoading && !isCartLoading
                                                      ? (bool value) {
                                                    setState(() {
                                                      _userWantsWallet = value;
                                                    });
                                                    _refreshCart();
                                                  }
                                                      : (value){}, // disables interaction while loading
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    OrderNoteWidget(
                                      onNoteChanged: (note) {
                                        setState(() {
                                          orderNote = note;
                                        });
                                      },
                                      isEnabled: !isCartLoading,
                                    ),
                                    BillSummaryWidget(
                                      itemsOriginalPrice: 0,
                                      itemsDiscountedPrice: billSummaryData!.itemsTotal?.toDouble() ?? 0,
                                      itemsSavings: 0,
                                      deliveryChargeOriginal: billSummaryData.totalDeliveryCharges?.toDouble() ?? 0,
                                      handlingCharge: billSummaryData.handlingCharges?.toDouble() ?? 0,
                                      grandTotal: billSummaryData.payableAmount?.toDouble() ?? 0,
                                      totalSavings: 0,
                                      perStoreDropOffFees: billSummaryData.perStoreDropOffFee?.toDouble() ?? 0.0,
                                      promoCode: billSummaryData.promoCode,
                                      promoDiscount: double.parse(billSummaryData.promoDiscount!),
                                      promoError: billSummaryData.promoError,
                                      removeCoupon: (){
                                        setState(() {
                                          isCartLoading = true;
                                          promoCode = '';
                                        });
                                        context.read<PromoCodeBloc>().add(RemovePromoCode());
                                        context.read<GetUserCartBloc>().add(FetchUserCart(
                                            addressId: selectedAddress?.id,
                                            rushDelivery: selectedDeliveryType == DeliveryType.rush,
                                            useWallet: _userWantsWallet,
                                            promoCode: promoCode ?? ''
                                        ));
                                      },
                                      promoMode: billSummaryData.promoApplied?.promoMode ?? '',
                                      discountAmount: billSummaryData.promoApplied?.discountAmount ?? '',
                                      isRushDelivery: billSummaryData.isRushDelivery,
                                    )
                                  ],
                                );
                              }
                              else {
                                isCartLoading = false;
                                return _buildEmptyCartState();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomNavigationBar: BlocBuilder<GetUserCartBloc, GetUserCartState>(
                  builder: (context, state) {
                    bool hasItems = true;
                    // Update total amount from cart data
                    if (state is GetUserCartLoaded) {
                      stateData = state.cartData;
                      if (stateData.isNotEmpty) {
                        hasItems = stateData.first.data?.items != null;
                      } else {
                        hasItems = false;
                      }
                    }

                    if(hasItems){
                      if (stateData.isNotEmpty) {
                        totalAmount = stateData.first.data?.paymentSummary!.payableAmount?.toDouble() ?? 0.0;
                      } else {
                        totalAmount = 0.0;
                      }
                      return BlocBuilder<CartUIBloc, CartUIState>(
                        builder: (context, uiState) {
                          final bool isSelfPickup =
                              uiState.selectedFulfillmentMode == FulfillmentMode.selfPickup;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelfPickup)
                                _buildPickupCard()
                              else if (selectedAddress != null)
                                DeliveryAddressWidget(
                                  selectedAddress: selectedAddress,
                                  onTap: () {
                                    _showAddressSelectionBottomSheet();
                                  },
                                ),
                              _buildCheckoutSection(isSelfPickup: isSelfPickup),
                            ],
                          );
                        },
                      );
                    }
                    else {
                      return const SizedBox.shrink();
                    }
                  },
                )
            ),
            if(isWholePageProgress)
              const WholePageProgress(),
          ],
        );
      },
    );
  }

  List<CartItem> _getProductsMissingRequiredAttachment(
      BuildContext context,
      List<CartItem> cartItems,
      ) {
    final attachmentState = context.read<AttachmentBloc>().state;
    final attachmentsMap = attachmentState is AttachmentLoaded
        ? attachmentState.attachments
        : <int, CartItemAttachment?>{};

    return cartItems.where((item) {
      // Only check products that require attachment
      if(item.product?.isAttachmentRequired == true) {
        if (item.product?.attachmentMode != 'required') {
          return false;
        } else {
          final attachment = attachmentsMap[item.productId ?? -1];
          return attachment == null;
        }
      } else {
        return false;
      }
    }).toList();
  }

  Future<bool> _showClearCartConfirmDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.clearAllItems,
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.of(context)!.allItemsWillBeRemovedCannotBeUndone,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n?.no ?? 'No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                l10n?.yesClear ?? 'Yes, clear',
                style: const TextStyle(
                    color: AppTheme.primaryColor
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _updateCartWithDeliveryType(DeliveryType type) {
    // Update your cart with the selected delivery type
    context.read<GetUserCartBloc>().add(FetchUserCart(
        addressId: selectedAddress?.id,
        rushDelivery: type == DeliveryType.rush,
        useWallet: _userWantsWallet,
        promoCode: promoCode ?? ''
    ));
  }

  Widget offerAndCouponButton (){
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () async {
        final result = await GoRouter.of(context).push(
            AppRoutes.promoCode,
          extra: {
            'cartAmount': stateData.first.data?.paymentSummary?.itemsTotal?.toDouble() ?? 0.0,
            'deliveryCharges': stateData.first.data?.paymentSummary?.totalDeliveryCharges?.toDouble() ?? 0.0,
          }
        );
        if(result != null && result is String && result.isNotEmpty){
          if(mounted){
            context.read<CartUIBloc>().add(SetCartLoading(true));
            promoCode = result;
            context.read<GetUserCartBloc>().add(FetchUserCart(
              addressId: selectedAddress?.id,
              promoCode: promoCode,
              rushDelivery: selectedDeliveryType == DeliveryType.rush,
              useWallet: _userWantsWallet,
            ));
          }
        }
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  TablerIcons.rosette_discount_filled, color: const Color(0xFF149400),
                  size: isTablet(context) ? 18.r : 26.r,
                ),
                SizedBox(width: 5.w,),
                Text(
                  l10n?.viewCouponOffers ?? 'View Coupon & Offers',
                  style: TextStyle(
                      fontSize: isTablet(context) ? 22 : 15.sp,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right)
          ],
        ),
      ),
    );
  }

  void _handleQuantityChanged(String itemId, int newQuantity) {
    log('On Quantity Change $newQuantity $itemId');
    setState(() {
      isCartLoading = true;
    });
    context.read<UpdateItemQuantityBloc>().add(UpdateItemQuantityRequest(
        cartItemId: int.parse(itemId),
        quantity: newQuantity,
    ));
  }

  void _handleRemoveItem(String itemId) {
    setState(() {
      isCartLoading = true;
    });
    context.read<RemoveItemFromCartBloc>().add(RemoveItemFromCartRequest(cartItemId: int.parse(itemId)));
  }

  void _handleAddMoreItems() {
    final l10n = AppLocalizations.of(context);
    // Navigate to products page or show add items dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n?.addMoreItemsTapped ?? 'Add more items tapped!')),
    );
  }

  void _showAddressSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => AddressSelectionBottomSheet(
        selectedAddress: selectedAddress,
        deliveryZoneId: deliveryZoneId,
        onAddressSelected: (address) {
          if(address.id != selectedAddress!.id) {
            setState(() {
              selectedAddress = address;
              selectedDeliveryType = DeliveryType.regular;
              isCartLoading = true;
            });
            // Save selected address to Hive
            HiveSelectedAddressHelper.setSelectedAddress(address);
            context.read<GetUserCartBloc>().add(FetchUserCart(
                addressId: address.id,
                useWallet: _userWantsWallet,
                rushDelivery: selectedDeliveryType == DeliveryType.rush,
                promoCode: promoCode
            ));
          }
        },
      ),
    );
  }

  void _navigateToPaymentOptions() async {
    final l10n = AppLocalizations.of(context);
    final bool isSelfPickup =
        context.read<CartUIBloc>().state.selectedFulfillmentMode == FulfillmentMode.selfPickup;
    if (!isSelfPickup && selectedAddress == null) {
      ToastManager.show(
          context: context,
          message: l10n?.pleaseSelectADeliveryAddressFirst ?? 'Please select a delivery address first',
          type: ToastType.error
      );
      return;
    }

    final paymentMethodType = await context.push(
      AppRoutes.paymentOptions,
      extra: {
        'totalAmount': totalAmount,
      },
    );

    if (paymentMethodType != null && paymentMethodType is PaymentMethodType) {
      final paymentMethod = PaymentConfig.getPaymentMethodByType(paymentMethodType);
      if (paymentMethod != null) {
        setState(() {
          selectedPaymentMethod = paymentMethod.id;
          selectedPaymentMethodType = paymentMethod.type;
        });
      }
    }
  }

  void _processOrder(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (totalAmount <= 0) {
      _initiatePayment();
      return;
    }

    if (selectedPaymentMethod == null) {
      ToastManager.show(
          context: context,
          message: l10n?.selectPaymentMethod ?? 'Please select a payment method first',
          type: ToastType.error
      );
      return;
    }

    // Process payment based on method
    if(selectedPaymentMethod != 'cod' && selectedPaymentMethodType != PaymentMethodType.flutterwave) {
      context.read<PaymentBloc>().add(
        InitiatePaymentEvent(
          paymentMethodType: selectedPaymentMethodType!,
          amount: totalAmount,
          additionalData: {
            'userId': Global.userData?.userId.toString() ?? '',
            'customerName': Global.userData?.name.toString() ?? '',
            'email': Global.userData?.email.toString() ?? '',
            'phone': Global.userData?.mobile.toString() ?? '',
            'deliveryAddress': selectedAddress != null
                ? formatAddressFromModel(selectedAddress!)
                : '',
          },
          addMoneyToWallet: false,
          context: context
        ),
      );
    } else {
      _initiatePayment();
    }
  }

  void _initiatePayment({String? paymentId, String? signature, String? orderId,}) {
    final attachmentState = context.read<AttachmentBloc>().state;
    final attachments = attachmentState is AttachmentLoaded
        ? attachmentState.attachments
        : <int, List<CartItemAttachment>>{};

    final l10n = AppLocalizations.of(context);
    final bool isSelfPickup =
        context.read<CartUIBloc>().state.selectedFulfillmentMode == FulfillmentMode.selfPickup;
    final String deliveryMode = isSelfPickup ? 'self_pickup' : 'delivery';
    if(totalAmount <= 0) {
      context.read<CreateOrderBloc>().add(CreateOrderRequest(
        paymentType: 'wallet',
        addressId: selectedAddress?.id ?? 0,
        rushDelivery: !isSelfPickup && selectedDeliveryType == DeliveryType.rush,
        promoCode: promoCode,
        paymentDetails: selectedPaymentMethod == 'razorpay'
            ? {
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
          'transaction_id': paymentId,
        } : selectedPaymentMethodType != PaymentMethodType.flutterwave ? {
          'transaction_id': paymentId,
        } : {},
        orderNote: orderNote,
        attachments: attachments,
        useWallet: _userWantsWallet,
        deliveryMode: deliveryMode,
      ));
      return;
    }
    if (selectedPaymentMethod == null && selectedPaymentMethodType == null) {
      ToastManager.show(
        context: context,
        message: l10n?.paymentMethodNotSelected ?? 'Payment method not selected',
        type: ToastType.error,
      );
      return;
    }

    context.read<CreateOrderBloc>().add(CreateOrderRequest(
      paymentType: selectedPaymentMethod!,
      addressId: selectedAddress?.id ?? 0,
      rushDelivery: !isSelfPickup && selectedDeliveryType == DeliveryType.rush,
      promoCode: promoCode,
      paymentDetails: selectedPaymentMethod == 'razorpay'
          ? {
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
        'transaction_id': paymentId,
      } : selectedPaymentMethodType != PaymentMethodType.flutterwave ? {
        'transaction_id': paymentId,
      } : {},
      orderNote: orderNote,
      attachments: attachments,
      useWallet: _userWantsWallet,
      deliveryMode: deliveryMode,
    ));
  }

  Widget _buildCheckoutSection({bool isSelfPickup = false}) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),
      child: (isSelfPickup || selectedAddress != null)
          ? Row(
        children: [
          if(totalAmount > 0.0)
            if(selectedPaymentMethod != null && selectedPaymentMethodType != null)...[
              // Selected payment method on the left
              InkWell(
                onTap: _navigateToPaymentOptions,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (selectedPaymentMethod != null && selectedPaymentMethodType != null) ...[
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: PaymentConfig.getPaymentMethodWidget(selectedPaymentMethod!, size: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (l10n?.payUsing ?? 'Pay Using').toUpperCase(),
                            style: TextStyle(
                                fontSize: 10.sp,
                                letterSpacing: 1.1
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Icon(
                            Icons.arrow_drop_up,
                          ),
                        ]
                      ],
                    ),
                    Text(
                      PaymentConfig.getPaymentMethodName(selectedPaymentMethod!),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          const SizedBox(height: 5),
          // Pay button on the right
          Expanded(
            child: SizedBox(
              height: 50,
              child: CustomButton(
                onPressed: isCartLoading
                    ? () {}
                    : () {


                  final bool isPlacingOrderNow =
                      totalAmount <= 0 || selectedPaymentMethod != null;
                  if (isPlacingOrderNow) {
                    final user = Global.userData;
                    final bool emailOk =
                        (user?.emailVerified ?? '').trim().isNotEmpty;
                    final bool mobileOk =
                        (user?.mobileVerified ?? '').trim().isNotEmpty;
                    if (!emailOk || !mobileOk) {
                      ToastManager.show(
                        context: context,
                        message: l10n?.pleaseVerifyEmailAndMobileBeforePlacingOrder
                            ?? 'Please verify your email and mobile number before placing the order.',
                        type: ToastType.error,
                      );
                      GoRouter.of(context).push(AppRoutes.userProfile);
                      return;
                    }
                  }

                  final storeIds = stateData.first.data!.items
                      .map((item) => item.storeId)
                      .where((id) => id != null)
                      .cast<int>()
                      .toSet();

                  final cartValidationError = CartValidation.validateCartForCheckout(
                    context: context,
                    cartTotal: totalAmount <= 0 && stateData.first.data!.paymentSummary!.walletAmountUsed! > 0 ? stateData.first.data!.paymentSummary!.walletAmountUsed! : totalAmount,
                    totalItemsCount: stateData.first.data!.items.length,
                    storeIds: storeIds,
                  );

                  if (cartValidationError != null) {
                    ToastManager.show(
                      context: context,
                      message: cartValidationError,
                    );
                    return;
                  }

                  // ────────────────────────────────────────────────
                  final missingAttachmentProducts = _getProductsMissingRequiredAttachment(
                    context,
                    stateData.first.data!.items,
                  );

                  if (missingAttachmentProducts.isNotEmpty) {
                    final productNames = missingAttachmentProducts
                        .map((p) => "• ${p.product?.name ?? 'Item'}")
                        .join("\n");

                    ToastManager.show(
                      context: context,
                      message: "Attachment required for:\n$productNames\nPlease add the required file(s).",
                      type: ToastType.error,
                      duration: const Duration(seconds: 5),
                    );
                    return;
                  }

                  // All validations passed → proceed
                  if (totalAmount <= 0 || selectedPaymentMethod != null) {
                    _processOrder(context);
                  } else {
                    _navigateToPaymentOptions();
                  }
                },
                child: isCartLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                )
                    : Text(
                  (selectedPaymentMethod != null || totalAmount <= 0.0) ? (l10n?.placeOrder ?? 'Place Order') : (l10n?.selectPaymentMethod ?? 'Select payment method'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : SizedBox(
        height: 50,
        width: double.infinity,
        child: CustomButton(
          onPressed: (){
            _navigateToAddAddress();
          },
          child: Text(
            AppLocalizations.of(context)!.chooseAddressForDelivery,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCartState() {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.yourCartIsEmpty ?? 'Your cart is empty',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.looksLikeYouHaventAddedAnythingYet ?? 'Looks like you haven\'t added anything yet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: CustomButton(
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                child: Text(
                  l10n?.browseProducts ?? 'Browse products',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddAddress() async {
    await GoRouter.of(context).push(
      AppRoutes.locationPicker,
      extra: {
        'isFromAddressPage': true,
        'isEdit': false,
        'isFromCartPage': true,
        'deliveryZoneId': deliveryZoneId
      },
    );
  }

  /// Returns whether the cart is eligible for self-pickup.
  /// TODO(master-catalog): default is false until the backend exposes
  /// `allow_self_pickup` per Store (and/or a SettingsBloc feature flag).
  /// When the API contract lands, iterate `cartData.first.data?.items` and
  /// AND the store-level flags; fall back to a SettingsBloc flag for global rollout.
  bool _computeIsSelfPickupAvailable(List<CartModel> cartData) {
    // Feature flag OFF in production. Keeping the toggle hidden prevents
    // backend rejections / bad orders until the contract is ready.
    return false;
  }

  Widget _buildPickupCard() {
    final l10n = AppLocalizations.of(context);
    Store? store;
    if (stateData.isNotEmpty) {
      final items = stateData.first.data?.items ?? const <CartItem>[];
      if (items.isNotEmpty) {
        store = items.first.store;
      }
    }
    final String storeName = store?.name ?? (l10n?.store ?? 'Store');
    // TODO(master-catalog): replace with store.address / store.lat / store.lng
    // once the Store model exposes them via the cart API contract.
    // TODO(master-catalog): replace literal with l10n + real Store address once
    // the Store model exposes address / lat / lng via the cart API contract.
    const String pickupAddress = 'Pickup address not available';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                TablerIcons.building_store,
                color: AppTheme.primaryColor,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l10n?.pickup ?? 'Pickup',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            storeName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            pickupAddress,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
            ),
          ),
          // TODO(master-catalog): restore Get-directions + Copy-address actions
          // (with `hasMapsLink`, `_openMapsForPickup`, Clipboard.setData, and
          // l10n keys getDirections / addressCopied / copyAddress /
          // pickupAddressNotAvailable) once the Store model exposes
          // address / lat / lng via the cart API contract.
        ],
      ),
    );
  }
}