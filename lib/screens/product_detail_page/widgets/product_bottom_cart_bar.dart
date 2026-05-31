import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_state.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/model/user_cart_model/cart_addon.dart';
import 'package:aasyou/model/user_cart_model/cart_sync_action.dart';
import 'package:aasyou/model/user_cart_model/user_cart.dart';
import 'package:aasyou/screens/product_detail_page/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:aasyou/screens/product_detail_page/bloc/product_detail_bloc/product_detail_state.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/screens/product_detail_page/widgets/price_row_widget.dart';
import 'package:aasyou/screens/product_detail_page/widgets/addon_picker_sheet.dart';
import 'package:aasyou/services/user_cart/cart_validation.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:aasyou/utils/widgets/customisations_bottom_sheet.dart';

class ProductBottomCartBar extends StatelessWidget {
  final Map<String, SwatchValues> selectedVariants;
  final VoidCallback? onAddNewCustomisation;

  const ProductBottomCartBar({
    super.key,
    required this.selectedVariants,
    this.onAddNewCustomisation,
  });

  ProductVariants _getActiveVariant(ProductData product) {
    if (selectedVariants.isEmpty) {
      return product.variants.firstWhere(
        (v) => v.isDefault,
        orElse: () => product.variants.first,
      );
    }

    return product.variants.firstWhere(
      (v) {
        for (var attr in product.attributes) {
          final selected = selectedVariants[attr.name];
          if (selected != null) {
            final variantValue = v.attributes[attr.slug];
            if (variantValue?.toString().toLowerCase().trim() !=
                selected.value.toString().toLowerCase().trim()) {
              return false;
            }
          }
        }
        return true;
      },
      orElse: () => product.variants.firstWhere(
        (v) => v.isDefault,
        orElse: () => product.variants.first,
      ),
    );
  }

  UserCart? _getCartItem(
    CartState state,
    int productId,
    int productVariantId,
    int storeId,
  ) {
    if (state is CartLoaded) {
      try {
        return state.items.firstWhere(
          (item) =>
              int.parse(item.productId) == productId &&
              int.parse(item.variantId) == productVariantId &&
              int.parse(item.vendorId) == storeId,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        if (state is! ProductDetailLoaded) {
          return const SizedBox.shrink();
        }

        final product = state.productData[0];
        final activeVariant = _getActiveVariant(product);

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Displayed price folds in the matched cart row's
              BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  final UserCart? priceCartItem = _getCartItem(
                    cartState,
                    product.id,
                    activeVariant.id,
                    activeVariant.storeId,
                  );
                  final double addonsAddPerUnit =
                      priceCartItem?.addonsTotal ?? 0.0;
                  final int qty = priceCartItem?.quantity ?? 1;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PriceRowWidget(
                          originalPrice:
                              (activeVariant.price.toDouble() +
                                      addonsAddPerUnit) *
                                  qty,
                          salePrice:
                              (activeVariant.specialPrice.toDouble() +
                                      addonsAddPerUnit) *
                                  qty,
                          fontSize: 12.sp,
                          originalFontSize: 10.sp,
                          discountFontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          originalPriceColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (product.isInclusiveTax)
                        Text(
                          l10n.inclusiveOfAllTax,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
              if (activeVariant.stock > 0)
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 120,
                        minWidth: 80,
                      ),
                      child: BlocBuilder<CartBloc, CartState>(
                        builder: (context, cartState) {
                          final cartItem = _getCartItem(
                            cartState,
                            product.id,
                            activeVariant.id,
                            activeVariant.storeId,
                          );
                          final isInCart = cartItem != null;

                          final bool hasCustomisations = activeVariant.addonGroups.isNotEmpty;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  height: 45,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isInCart
                                        ? AppTheme.primaryColor
                                        : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale:
                                              Tween<double>(begin: 0.85, end: 1.0)
                                                  .animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: isInCart
                                        ? _QuantityStepper(
                                            key: const ValueKey('stepper_inner'),
                                            cartItem: cartItem,
                                            product: product,
                                            activeVariant: activeVariant,
                                            hasCustomisations: hasCustomisations,
                                            onAddNewCustomisation:
                                                onAddNewCustomisation,
                                          )
                                        : _AddButton(
                                            key:
                                                const ValueKey('add_button_inner'),
                                            product: product,
                                            selectedVariants: selectedVariants,
                                            cartItem: cartItem,
                                            onOpenAddonPicker:
                                                (selectedVariant) {
                                              showAddonPickerSheet(
                                                context: context,
                                                product: product,
                                                selectedVariant: selectedVariant,
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              ),
                              if (hasCustomisations) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  l10n.customisable,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error,
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    l10n.outOfStock,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final UserCart cartItem;
  final ProductData product;
  final ProductVariants activeVariant;
  final bool hasCustomisations;
  final VoidCallback? onAddNewCustomisation;

  const _QuantityStepper({
    super.key,
    required this.cartItem,
    required this.product,
    required this.activeVariant,
    this.hasCustomisations = false,
    this.onAddNewCustomisation,
  });

  void _openCustomisationsSheet(BuildContext context) {
    showCustomisationsBottomSheet(
      context: context,
      productId: product.id,
      storeId: activeVariant.storeId,
      productName: product.title,
      productSlug: product.slug,
      productImage: product.mainImage,
      quantityStepSize: product.quantityStepSize,
      minQty: product.minimumOrderQuantity,
      totalAllowedQuantity: product.totalAllowedQuantity,
      isStoreOpen: product.storeStatus?.isOpen ?? true,
      onAddNewCustomisation: onAddNewCustomisation ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await HapticFeedback.lightImpact();
              if (hasCustomisations) {
                if (context.mounted) _openCustomisationsSheet(context);
                return;
              }
              if (cartItem.quantity > product.quantityStepSize) {
                if (context.mounted) {
                  context.read<CartBloc>().add(
                        UpdateCartQty(
                          cartKey: cartItem.cartKey,
                          quantity:
                              cartItem.quantity - product.quantityStepSize,
                          cartItemId: cartItem.serverCartItemId,
                          context: context,
                        ),
                      );
                }
              } else {
                if (context.mounted) {
                  context.read<CartBloc>().add(
                        RemoveFromCart(
                          cartKey: cartItem.cartKey,
                          context: context,
                        ),
                      );
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Icon(
                TablerIcons.minus,
                size: 20.r,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            cartItem.quantity.toString(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await HapticFeedback.lightImpact();
              // Customisable products: route through the sheet so the user
              if (hasCustomisations) {
                if (context.mounted) _openCustomisationsSheet(context);
                return;
              }
              if (context.mounted) {
                final error = CartValidation.validateProductAddToCart(
                  context: context,
                  requestedQuantity:
                      cartItem.quantity + product.quantityStepSize,
                  minQty: product.minimumOrderQuantity,
                  maxQty: product.totalAllowedQuantity,
                  stock: activeVariant.stock,
                  isStoreOpen: product.storeStatus!.isOpen,
                );

                if (error != null) {
                  ToastManager.show(
                    context: context,
                    message: error,
                    type: ToastType.error,
                  );
                  return;
                } else {
                  context.read<CartBloc>().add(
                        UpdateCartQty(
                          cartKey: cartItem.cartKey,
                          quantity:
                              cartItem.quantity + product.quantityStepSize,
                          cartItemId: cartItem.serverCartItemId,
                          context: context,
                        ),
                      );
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Icon(
                TablerIcons.plus,
                size: 20.r,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final ProductData product;
  final Map<String, SwatchValues> selectedVariants;
  final UserCart? cartItem;

  final void Function(ProductVariants variant)? onOpenAddonPicker;

  const _AddButton({
    super.key,
    required this.product,
    required this.selectedVariants,
    required this.cartItem,
    this.onOpenAddonPicker,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: CustomButton(
        onPressed: () {
          final isStoreOpen = product.storeStatus?.isOpen ?? true;

          // Resolve selected variant using all selected attributes
          ProductVariants? selectedVariant;

          if (product.attributes.isNotEmpty) {
            if (selectedVariants.isEmpty) {
              ToastManager.show(
                context: context,
                message: l10n.pleaseSelectVariant,
                type: ToastType.error,
              );
              return;
            }

            selectedVariant = product.variants.firstWhere(
              (v) {
                for (var attr in product.attributes) {
                  final selected = selectedVariants[attr.name];
                  if (selected != null) {
                    final variantValue = v.attributes[attr.slug];
                    if (variantValue?.toString().toLowerCase().trim() !=
                        selected.value.toString().toLowerCase().trim()) {
                      return false;
                    }
                  }
                }
                return true;
              },
              orElse: () =>
                  product.variants.firstWhere((v) => v.isDefault),
            );
          } else {
            selectedVariant =
                product.variants.firstWhere((v) => v.isDefault);
          }

          if (selectedVariant.addonGroups.isNotEmpty) {
            onOpenAddonPicker?.call(selectedVariant);
            return;
          }

          // No-addon path — direct add.
          final cartBloc = context.read<CartBloc>();

          final requestedQty = cartItem != null
              ? cartItem!.quantity + product.quantityStepSize
              : product.quantityStepSize;

          final productError = CartValidation.validateProductAddToCart(
            context: context,
            requestedQuantity: requestedQty,
            minQty: product.minimumOrderQuantity,
            maxQty: product.totalAllowedQuantity,
            stock: selectedVariant.stock,
            isStoreOpen: isStoreOpen,
          );

          if (productError != null) {
            ToastManager.show(
              context: context,
              message: productError,
              type: ToastType.error,
            );
            return;
          }

          final item = UserCart(
            productId: product.id.toString(),
            variantId: selectedVariant.id.toString(),
            variantName: selectedVariant.title,
            vendorId: selectedVariant.storeId.toString(),
            name: product.title,
            image: product.mainImage,
            price: selectedVariant.specialPrice.toDouble(),
            originalPrice: selectedVariant.price.toDouble(),
            quantity: product.quantityStepSize,
            serverCartItemId: null,
            syncAction: CartSyncAction.add,
            updatedAt: DateTime.now(),
            minQty: product.minimumOrderQuantity,
            maxQty: product.totalAllowedQuantity,
            isOutOfStock: selectedVariant.stock <= 0,
            isSynced: false,
            addons: const <CartAddon>[],
          );

          cartBloc.add(AddToCart(item: item, context: context));
        },
        child: Text(
          l10n.add,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}