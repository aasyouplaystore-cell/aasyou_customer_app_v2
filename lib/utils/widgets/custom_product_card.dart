import 'package:animations/animations.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart'
    show Badge;
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/product_detail_page/view/product_detail_page.dart';
import 'package:aasyou/services/auth_guard.dart';
import 'package:aasyou/utils/widgets/animated_button.dart';
import 'package:aasyou/utils/widgets/price_utils.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import 'package:aasyou/utils/widgets/product_indicator.dart';
import 'package:aasyou/utils/widgets/hero_tags.dart';
import 'package:aasyou/utils/widgets/sponsored_badge.dart';
import '../../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../../bloc/user_cart_bloc/user_cart_event.dart';
import '../../bloc/user_cart_bloc/user_cart_state.dart';
import '../../config/global.dart';
import '../../config/helper.dart';
import '../../l10n/app_localizations.dart';
import '../../model/user_cart_model/user_cart.dart';
import '../../screens/wishlist_page/widgets/wishlist_bottom_sheet.dart';
import '../../screens/wishlist_page/bloc/get_user_wishlist_bloc/get_user_wishlist_bloc.dart';
import '../../screens/wishlist_page/bloc/get_user_wishlist_bloc/get_user_wishlist_state.dart';
import 'package:flutter/services.dart';
import '../../services/user_cart/cart_validation.dart';
import 'custom_toast.dart';
import 'customisations_bottom_sheet.dart';

class CustomProductCard extends StatelessWidget {
  final int productId;
  final String productImage;
  final String productName;
  final String productSlug;
  final String productPrice;
  final List<String> productTags;
  final String specialPrice;
  final String estimatedDeliveryTime;
  final String? assetImage;
  final double ratings;
  final int ratingCount;
  final VoidCallback onAddToCart;
  final bool isStoreOpen;
  final bool isWishListed;
  final int productVariantId;
  final int storeId;
  final int wishlistItemId;
  final int totalStocks;
  final String imageFit;
  final bool showWishlist;
  final int? variantCount;
  final VoidCallback? onVariantSelectorRequested;
  final int quantityStepSize;
  final int minQty;
  final int totalAllowedQuantity;
  final String? indicator;
  final bool isRecommended;
  final bool isSponsored;
  final VoidCallback? onCardTap;
  final Badge? badge;

  const CustomProductCard({
    super.key,
    required this.productId,
    required this.productImage,
    required this.productName,
    required this.productSlug,
    required this.productPrice,
    required this.productTags,
    this.assetImage,
    required this.specialPrice,
    required this.estimatedDeliveryTime,
    required this.ratings,
    required this.ratingCount,
    required this.onAddToCart,
    required this.isStoreOpen,
    required this.isWishListed,
    required this.productVariantId,
    required this.storeId,
    required this.wishlistItemId,
    required this.totalStocks,
    required this.imageFit,
    this.showWishlist = true,
    this.variantCount,
    this.onVariantSelectorRequested,
    required this.quantityStepSize,
    required this.minQty,
    required this.totalAllowedQuantity,
    this.indicator,
    this.isRecommended = false,
    this.isSponsored = false,
    this.onCardTap,
    this.badge,
  });

  BoxFit get _boxFit {
    switch (imageFit.toLowerCase()) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
      default:
        return BoxFit.contain;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDim = totalStocks <= 0 || !isStoreOpen;
    final discountPct = PriceUtils.calculateDiscountPercentage(
      double.tryParse(productPrice) ?? 0,
      double.tryParse(specialPrice) ?? 0,
    );
    final hasDiscount = discountPct > 0;

    return OpenContainer(
      clipBehavior: Clip.antiAlias,
      transitionDuration: const Duration(milliseconds: 500),
      transitionType: ContainerTransitionType.fade,
      closedElevation: 0,
      openElevation: 0,
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      openShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      tappable: false,
      useRootNavigator: true,
      closedBuilder: (context, openContainer) {
        return GestureDetector(
          onTap: () {
            onCardTap?.call();
            openContainer();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ColorFiltered(
              colorFilter: isDim
                  ? ColorFilter.mode(
                Colors.black.withValues(alpha: 0.1),
                BlendMode.srcATop,
              )
                  : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imageSection(
                    context: context,
                    isDim: isDim,
                    discountPct: discountPct,
                    hasDiscount: hasDiscount,
                  ),
                  _infoSection(
                    context: context,
                    isDim: isDim,
                    discountPct: discountPct,
                    hasDiscount: hasDiscount,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      openBuilder: (context, closeContainer) {
        return ProductDetailPage(
          productSlug: productSlug,
          initialData: ProductInitialData(
            title: productName,
            mainImage: productImage,
          ),
          closeContainer: closeContainer,
        );
      },
    );
  }

  // ── Image section ──────────────────────────────────────────────────────────
  Widget _imageSection({
    required BuildContext context,
    required bool isDim,
    required int discountPct,
    required bool hasDiscount,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Base image container
          Container(
            margin: EdgeInsetsDirectional.only(end: 8.w, bottom: 6.h),
            width: double.infinity,
            height: 100.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: _boxFit == BoxFit.contain
                ? const EdgeInsets.all(10.0)
                : EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: productImage.isNotEmpty
                  ? Hero(
                      tag: productHeroTag(productSlug),
                      child: ColorFiltered(
                        colorFilter: isDim
                            ? const ColorFilter.matrix([
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ])
                            : const ColorFilter.mode(
                                Colors.transparent, BlendMode.multiply),
                        child: CustomImageContainer(
                            imagePath: productImage, fit: _boxFit),
                      ),
                    )
                  : _buildAssetImageOrPlaceholder(),
            ),
          ),

          // ── top-left: status › API badge › discount badge ──
          if (isDim)
            PositionedDirectional(
              top: 0,
              start: 0,
              child: _statusBadge(context),
            )
          else if (badge?.label?.isNotEmpty == true)
            PositionedDirectional(
              top: 0,
              start: 0,
              child: _apiBadgeWidget(context),
            ),

          // ── top-right: wishlist ──
          if (!isDim && showWishlist)
            PositionedDirectional(
              top: 2.h,
              end: 8.w,
              child: _wishlistButton(context),
            ),

          // ── bottom-left: Ad / Sponsored chip ──
          if (!isDim && isSponsored)
            PositionedDirectional(
              bottom: 10.h,
              start: 6.w,
              child: const SponsoredBadge(style: SponsoredBadgeStyle.chip),
            ),

          // ── bottom-right (upper): veg / non-veg indicator ──
          if (!isDim &&
              indicator != null &&
              (indicator == 'veg' || indicator == 'non_veg'))
            PositionedDirectional(
              // sits just above the ADD pill (26.h tall + 8.h offset + 4.h gap)
              bottom: 35.h,
              end: 12.w,
              child: productIndicator(indicator!),
            ),

          // ── bottom-right: pill ADD / stepper ──
          if (!isDim)
            PositionedDirectional(
              bottom: 6.h,
              end: 3.w,
              child: _cartButton(context),
            ),
        ],
      ),
    );
  }

  // ── Info section (order: price → dashed divider → name → rating → delivery) ──

  Widget _infoSection({
    required BuildContext context,
    required bool isDim,
    required int discountPct,
    required bool hasDiscount,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Price row — directly under image
          _priceRow(context, isDim),

          // 2. Dashed divider with discount label
          if (hasDiscount) _dashedDiscountDivider(context, discountPct),

          SizedBox(height: 2.h),

          // 3. Product name
          _productNameWidget(context, isDim),

          SizedBox(height: 5.h),

          // 4. Rating + review count (only when both are non-zero)
          if (ratings > 0 && ratingCount > 0) ...[
            _ratingWidget(context),
            SizedBox(height: 4.h),
          ],

          // 5. Delivery time
          Row(
            children: [
              Icon(TablerIcons.bolt_filled, size: 13, color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6),),
              const SizedBox(width: 1,),
              Text(
                '$estimatedDeliveryTime mins',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'inter',
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6),
                  height: 1.2
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  // ── Image overlay helpers ──────────────────────────────────────────────────

  Widget _statusBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(8.r),
          bottomEnd: Radius.circular(4.r),
        ),
      ),
      child: Text(
        isStoreOpen == false
            ? (AppLocalizations.of(context)?.storeClosed ?? 'Closed')
            : (AppLocalizations.of(context)?.outOfStock ?? 'Out of stock'),
        style: TextStyle(
          fontSize: isTablet(context) ? 12 : 8.sp,
          color: Colors.white,
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _apiBadgeWidget(BuildContext context) {
    final bgColor = _hexToColor(badge!.bgColor) ?? AppTheme.discountCardColor;
    final textColor = _hexToColor(badge!.textColor) ?? Colors.white;
    final borderColor = _hexToColor(badge!.borderColor);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 80.w),
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(8.r),
          bottomEnd: Radius.circular(4.r),
        ),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: Text(
        capitalizeFirstLetter(badge!.label!),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isTablet(context) ? 12 : 8.sp,
          color: textColor,
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    );
  }

  Widget _wishlistButton(BuildContext context) {
    return BlocBuilder<UserWishlistBloc, UserWishlistState>(
      builder: (context, wishlistState) {
        final bloc = context.read<UserWishlistBloc>();
        final isWishListedFromBloc =
            bloc.isProductWishlisted(productId, productVariantId, storeId);
        final currentWishlistItemId =
            bloc.getWishlistItemId(productId, productVariantId, storeId);
        final hasBlocData =
            bloc.hasProductData(productId, productVariantId, storeId);

        final finalIsWishListed =
            hasBlocData ? isWishListedFromBloc : isWishListed;
        final finalWishlistItemId = currentWishlistItemId ?? wishlistItemId;

        return AnimatedButton(
          onTap: () async {
            if (Global.userData != null) {
              context.read<UserWishlistBloc>().add(GetUserWishlistRequest());
              await showModalBottomSheet<String>(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                constraints: BoxConstraints(maxHeight: 500.h),
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => AddToWishlistSheetBody(
                  productId: productId,
                  productVariantId: productVariantId,
                  storeId: storeId,
                  wishlistItemId: finalWishlistItemId,
                ),
              );
            } else {
              await AuthGuard.ensureLoggedIn(context);
            }
          },
          child: Container(
            height: 28.r,
            width: 28.r,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🔲 Outline (Black border)
                Icon(
                  finalIsWishListed
                      ? AppHelpers.wishListedIcon
                      : AppHelpers.notWishListedIcon,
                  color: Colors.black,
                  size: 17.r,
                ),

                Icon(
                  finalIsWishListed
                      ? AppHelpers.wishListedIcon
                      : AppHelpers.notWishListedIcon,
                  color: Colors.white,
                  size: 15.r, // slightly smaller
                ),
              ],
            ),
          )
        );
      },
    );
  }

  Widget _cartButton(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final cartItem = _getCartItem(state);
        final isInCart = cartItem != null;
        final totalQtyAcrossVariants = _getTotalQuantityAcrossVariants(state);
        final Set<int> currentStoreIds = {};
        int currentTotalItems = 0;

        if (state is CartLoaded) {
          currentStoreIds.addAll(
            state.items
                .map((item) => int.tryParse(item.vendorId))
                .where((id) => id != null)
                .cast<int>(),
          );
          currentTotalItems = state.items.length;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          // Pill expands from icon-only to full stepper
          width: isInCart ? 80 : 28.h,
          height: 26.h,
          decoration: BoxDecoration(
            color: isInCart
                ? AppTheme.primaryColor
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: AppTheme.primaryColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: isInCart
                ? _QuantityStepper(
                    key: const ValueKey('stepper_v2'),
                    quantity: totalQtyAcrossVariants,
                    currentLocalQty: cartItem.quantity,
                    stepSize: quantityStepSize,
                    isStoreOpen: isStoreOpen,
                    stock: totalStocks,
                    minQty: minQty,
                    totalAllowedQuantity: totalAllowedQuantity,
                    onIncrement: () => _handleIncrement(context, cartItem),
                    onDecrement: () => _handleDecrement(context, cartItem),
                  )
                : _AddButton(
                    key: const ValueKey('add_v2'),
                    currentLocalQty: cartItem?.quantity ?? 0,
                    stepSize: quantityStepSize,
                    isStoreOpen: isStoreOpen,
                    stock: totalStocks,
                    minQty: minQty,
                    totalAllowedQuantity: totalAllowedQuantity,
                    opacity: totalStocks > 0 ? 1.0 : 0.5,
                    onTap: totalStocks > 0
                        ? () async {
                            await HapticFeedback.lightImpact();
                            if (!context.mounted) return;
                            final error =
                                CartValidation.validateProductAddToCart(
                              context: context,
                              requestedQuantity: quantityStepSize,
                              minQty: minQty,
                              maxQty: totalAllowedQuantity,
                              stock: totalStocks,
                              isStoreOpen: isStoreOpen,
                            );
                            final cartError =
                                CartValidation.validateBeforeAddToCart(
                              context: context,
                              currentCartItemCount: currentTotalItems,
                              requestedAddQuantity: quantityStepSize,
                              currentStoreIdsInCart: currentStoreIds,
                              thisProductStoreId: storeId,
                            );
                            if (error != null || cartError != null) {
                              ToastManager.show(
                                context: context,
                                message: cartError ?? error!,
                                type: ToastType.error,
                              );
                            } else {
                              onAddToCart();
                            }
                          }
                        : null,
                  ),
          ),
        );
      },
    );
  }

  // ── Info section helpers ───────────────────────────────────────────────────

  Widget _priceRow(BuildContext context, bool isDim) {
    final double regular = double.tryParse(productPrice) ?? 0.0;
    final double special = double.tryParse(specialPrice) ?? 0.0;
    final bool hasDiscount = special > 0 && special < regular;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Special (or regular) price — prominent
        Text(
          PriceUtils.formatPrice(hasDiscount ? special : regular),
          style: TextStyle(
            fontSize: isTablet(context) ? 22 : 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
            color: isDim
                ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5)
                : null
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (hasDiscount) ...[
          SizedBox(width: 5.w),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              PriceUtils.formatPrice(regular),
              style: TextStyle(
                fontSize: isTablet(context) ? 16 : 12.sp,
                decoration: TextDecoration.lineThrough,
                decorationColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                decorationThickness: 1.5,
                color: isDim
                    ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.onSecondaryContainer,
                fontFamily: AppTheme.fontFamily,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  /// Horizontal dashed line on both sides with the discount % label centred.
  Widget _dashedDiscountDivider(BuildContext context, int discountPct) {
    final lineColor = Theme.of(context)
        .colorScheme
        .onSecondaryContainer
        .withValues(alpha: 0.25);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.directional(end: 9.w),
            child: Text(
              '$discountPct% OFF',
              style: TextStyle(
                fontSize: isTablet(context) ? 14 : 11.sp,
                color: AppTheme.discountCardColor,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsGeometry.directional(end: 5.w),
              child: SizedBox(
                height: 1.0,
                child: CustomPaint(painter: _DashedLinePainter(color: lineColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productNameWidget(BuildContext context, bool isDim) {
    return SizedBox(
      // height: isTablet(context) ? 50 : 38,
      child: Text(
        productName,
        style: TextStyle(
          fontSize: isTablet(context) ? 19 : 13,
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w400,
          color: isDim ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5) : null
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _ratingWidget(BuildContext context) {
    return Row(
      children: [
        RatingBar.builder(
          initialRating: ratings,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 11.h,
          itemBuilder: (context, _) => const Icon(
            AppTheme.ratingStarIconFilled,
            color: AppTheme.ratingStarColor,
          ),
          unratedColor: Colors.grey[350],
          onRatingUpdate: (_) {},
          ignoreGestures: true,
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            '($ratingCount)',
            style: TextStyle(
              fontSize: isTablet(context) ? 18 : 8.sp,
              fontFamily: AppTheme.fontFamily,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  // ── Cart event handlers ───────────────────────────────────────────────────

  void _handleIncrement(BuildContext context, UserCart cartItem) async {
    await HapticFeedback.lightImpact();
    final bool hasCustomisations =
        (variantCount != null && variantCount! > 1) ||
            cartItem.addons.isNotEmpty;
    if (hasCustomisations && onVariantSelectorRequested != null) {
      if (context.mounted) {
        showCustomisationsBottomSheet(
          context: context,
          productId: productId,
          storeId: storeId,
          productName: productName,
          productSlug: productSlug,
          productImage: productImage,
          quantityStepSize: quantityStepSize,
          minQty: minQty,
          totalAllowedQuantity: totalAllowedQuantity,
          isStoreOpen: isStoreOpen,
          indicator: indicator,
          onAddNewCustomisation: onVariantSelectorRequested!,
        );
      }
      return;
    }
    if (!context.mounted) return;
    final error = CartValidation.validateProductAddToCart(
      context: context,
      requestedQuantity: cartItem.quantity + quantityStepSize,
      minQty: minQty,
      maxQty: totalAllowedQuantity,
      stock: totalStocks,
      isStoreOpen: isStoreOpen,
    );
    if (error != null) {
      ToastManager.show(context: context, message: error, type: ToastType.error);
    } else {
      context.read<CartBloc>().add(
            UpdateCartQty(
              cartKey: cartItem.cartKey,
              quantity: cartItem.quantity + quantityStepSize,
              cartItemId: cartItem.serverCartItemId,
              context: context,
            ),
          );
    }
  }

  void _handleDecrement(BuildContext context, UserCart cartItem) async {
    await HapticFeedback.lightImpact();
    final bool hasCustomisations =
        (variantCount != null && variantCount! > 1) ||
            cartItem.addons.isNotEmpty;
    if (hasCustomisations && onVariantSelectorRequested != null) {
      if (context.mounted) {
        showCustomisationsBottomSheet(
          context: context,
          productId: productId,
          storeId: storeId,
          productName: productName,
          productSlug: productSlug,
          productImage: productImage,
          quantityStepSize: quantityStepSize,
          minQty: minQty,
          totalAllowedQuantity: totalAllowedQuantity,
          isStoreOpen: isStoreOpen,
          indicator: indicator,
          onAddNewCustomisation: onVariantSelectorRequested!,
        );
      }
      return;
    }
    if (!context.mounted) return;
    if (cartItem.quantity > quantityStepSize) {
      context.read<CartBloc>().add(
            UpdateCartQty(
              cartKey: cartItem.cartKey,
              quantity: cartItem.quantity - quantityStepSize,
              cartItemId: cartItem.serverCartItemId,
              context: context,
            ),
          );
    } else {
      context.read<CartBloc>().add(
            RemoveFromCart(cartKey: cartItem.cartKey, context: context),
          );
    }
  }

  // ── Misc helpers ──────────────────────────────────────────────────────────

  int _getTotalQuantityAcrossVariants(CartState state) {
    if (state is! CartLoaded) return 0;
    return state.items
        .where((item) =>
            int.tryParse(item.productId) == productId &&
            int.tryParse(item.vendorId) == storeId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  UserCart? _getCartItem(CartState state) {
    if (state is CartLoaded) {
      try {
        return state.items.firstWhere(
          (item) =>
              int.parse(item.productId) == productId &&
              int.parse(item.vendorId) == storeId,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Widget _buildAssetImageOrPlaceholder() {
    if (assetImage != null && assetImage!.isNotEmpty) {
      return CustomImageContainer(imagePath: assetImage!, fit: BoxFit.cover);
    }
    return Builder(
      builder: (context) => Container(
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          size: 24.sp,
        ),
      ),
    );
  }
}

// ── Private inner widgets ─────────────────────────────────────────────────────
/// Pill-shaped ADD button — + icon only, no text label.
class _AddButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double opacity;
  final int currentLocalQty;
  final int stepSize;
  final int minQty;
  final int totalAllowedQuantity;
  final int stock;
  final bool isStoreOpen;

  const _AddButton({
    required Key key,
    required this.onTap,
    required this.opacity,
    required this.currentLocalQty,
    required this.stepSize,
    required this.minQty,
    required this.totalAllowedQuantity,
    required this.stock,
    required this.isStoreOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final error = CartValidation.validateProductAddToCart(
            context: context,
            requestedQuantity: currentLocalQty + stepSize,
            minQty: minQty,
            maxQty: totalAllowedQuantity,
            stock: stock,
            isStoreOpen: isStoreOpen,
          );
          if (error != null) {
            ToastManager.show(
                context: context, message: error, type: ToastType.error);
          } else {
            onTap?.call();
          }
        },
        child: SizedBox(
          width: 44,
          height: 26.h,
          child: Center(
            child: Icon(
              TablerIcons.plus,
              size: 18.r,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped `− qty +` stepper shown when the item is in the cart.
class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int currentLocalQty;
  final int stepSize;
  final int minQty;
  final int totalAllowedQuantity;
  final int stock;
  final bool isStoreOpen;

  const _QuantityStepper({
    required Key key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.currentLocalQty,
    required this.stepSize,
    required this.minQty,
    required this.totalAllowedQuantity,
    required this.stock,
    required this.isStoreOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDecrement,
            child: SizedBox(
              height: 26.h,
              child: Icon(TablerIcons.minus, size: 14.r, color: Colors.white),
            ),
          ),
        ),
        Text(
          quantity.toString(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onIncrement,
            child: SizedBox(
              height: 26.h,
              child: Icon(TablerIcons.plus, size: 14.r, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Parses a CSS-style hex color string (`#RGB`, `#RRGGBB`, `#AARRGGBB`) to [Color].
Color? _hexToColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleaned = hex.replaceAll('#', '');
  final expanded = cleaned.length == 3
      ? cleaned.split('').map((c) => '$c$c').join()
      : cleaned;
  final withAlpha = expanded.length == 6 ? 'FF$expanded' : expanded;
  final value = int.tryParse(withAlpha, radix: 16);
  return value != null ? Color(value) : null;
}

/// Draws a horizontal dashed line across the full available width.
class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 3.5;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
