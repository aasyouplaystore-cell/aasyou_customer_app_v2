import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/home_page/model/featured_section_product_model.dart';
import '../../../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../../../bloc/user_cart_bloc/user_cart_event.dart';
import '../../../config/helper.dart';
import '../../../model/user_cart_model/cart_sync_action.dart';
import '../../../model/user_cart_model/user_cart.dart';
import '../../../utils/widgets/bottom_variant_selector_with_addons.dart';
import '../../../utils/widgets/custom_product_card.dart';
import '../../ad_campaign/bloc/ad_click_bloc/ad_click_bloc.dart';
import '../../ad_campaign/widgets/ad_visibility_observer.dart';
import '../../product_listing_page/model/product_listing_type.dart';

enum FeatureSectionStyle { withBackground, withoutBackground }
enum FeatureSectionBackgroundType { image, color, none}

FeatureSectionStyle _parseStyle(String s) {
  return s == 'with_background'
      ? FeatureSectionStyle.withBackground
      : FeatureSectionStyle.withoutBackground;
}

FeatureSectionBackgroundType _parseBgType(String? s) {
  final v = (s ?? '').trim().toLowerCase();
  switch (v) {
    case 'image':
      return FeatureSectionBackgroundType.image;
    case 'color':
      return FeatureSectionBackgroundType.color;
    default:
      return FeatureSectionBackgroundType.none;
  }
}

class ProductFeatureSectionWidget extends StatefulWidget {
  final FeaturedSectionData featureSectionData;
  final String featureSectionTitle;
  final String featureSectionSlug;
  final String backgroundImage;
  final String backgroundImageTablet;
  final String featureSectionStyle;
  final String? backgroundColor;
  final String? backgroundType;


  const ProductFeatureSectionWidget({
    super.key,
    required this.featureSectionData,
    required this.featureSectionTitle,
    required this.backgroundImage,
    required this.backgroundImageTablet,
    required this.featureSectionSlug,
    required this.featureSectionStyle,
    this.backgroundColor,
    this.backgroundType,
  });

  @override
  State<ProductFeatureSectionWidget> createState() => _ProductFeatureSectionWidgetState();
}

class _ProductFeatureSectionWidgetState extends State<ProductFeatureSectionWidget> {
  final ScrollController featuredSectionScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final products = widget.featureSectionData.products;
    if (products.isEmpty) return const SizedBox.shrink();

    final style = _parseStyle(widget.featureSectionStyle);
    final isTabletTablet = isTablet(context);

    final bgUrl = isTabletTablet
        ? (widget.backgroundImageTablet.isNotEmpty == true
        ? widget.backgroundImageTablet
        : widget.backgroundImage)
        : widget.backgroundImage;
    final hasBgImage = bgUrl.isNotEmpty;
    final hasBgColor = widget.backgroundColor != null;
    final bgType = _parseBgType(widget.backgroundType);

    switch (style) {

      case FeatureSectionStyle.withBackground:
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Stack(
            children: [
              // Background layers (image or color) – remains the same
              if (bgType == FeatureSectionBackgroundType.image && hasBgImage)
                Positioned(
                  top: 15,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    width: double.infinity,
                    height: isTabletTablet ? 350 : 200,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: bgUrl,
                    ),
                  ),
                )
              else if (bgType == FeatureSectionBackgroundType.color && hasBgColor)
                Positioned(
                  top: 15,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: isTabletTablet ? 350 : 200,
                    color: hexStringToColor(widget.backgroundColor),
                  ),
                ),

              Container(
                color: Colors.transparent,
                height: isTabletTablet ? 125.h : 326.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isTabletTablet ? 70.h : 80.w),
                    _buildHeader(context, isTabletTablet),
                    _buildProductsList(context, isTabletTablet),
                  ],
                ),
              ),
            ],
          ),
        );

      case FeatureSectionStyle.withoutBackground:
        return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: SizedBox(
            height: 266.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isTablet(context)),
                const SizedBox(height: 8),
                _buildProductsList(context, isTablet(context)),
              ],
            ),
          ),
        );
    }
  }

  bool _shouldShowTitle() {
    final style = _parseStyle(widget.featureSectionStyle);

    if (style == FeatureSectionStyle.withoutBackground) {
      return true;
    }

    if (style == FeatureSectionStyle.withBackground) {
      final bgType = _parseBgType(widget.backgroundType);
      // Hide title only when we actually have a background image
      return bgType != FeatureSectionBackgroundType.image ||
          widget.backgroundImage.isEmpty && widget.backgroundImageTablet.isEmpty;
    }

    return true;
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    final showTitle = _shouldShowTitle();
    final titleText = widget.featureSectionData.title ?? '';

    return Padding(
      padding: EdgeInsets.only(
        left: isTablet ? 20.0 : 10.0,
        right: isTablet ? 20.0 : 10.0,
        bottom: 10.0.h,
      ),
      child: Row(
        mainAxisAlignment:
        showTitle ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
        children: [
          if (showTitle)
            Text(
              titleText,
              style: TextStyle(
                fontSize: isTablet ? 24 : 17,
                fontWeight: FontWeight.bold,
                color: (isDarkMode(context) ? Colors.white : Colors.black87),
              ),
            ),

          InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () {
              GoRouter.of(context).pushNamed(
                'product-listing',
                extra: {
                  'isTheirMoreCategory': false,
                  'title': titleText,
                  'logo': '',
                  'totalProduct': widget.featureSectionData.productsCount,
                  'type': ProductListingType.featuredSection,
                  'identifier': widget.featureSectionSlug,
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 10.w : 6.w,
                vertical: isTablet ? 4.h : 2.h,
              ),
              decoration: showTitle
                  ? null
                  : BoxDecoration(
                color: isDarkMode(context)
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: TextStyle(
                  color: !_shouldShowTitle() ? Colors.black : Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 18 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, bool isTablet) {
    final products = widget.featureSectionData.products;
    return SizedBox(
      height: 225.h,
      child: ListView.builder(
        controller: featuredSectionScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(
          left: isTablet ? 20 : 10,
          right: isTablet ? 20 : 10,
        ),
        itemCount: products.length > 8 ? 8 : products.length,
        itemBuilder: (context, index) {
          final data = products[index];
          final defaultVariant = data.variants.firstWhere(
                (v) => v.isDefault,
            orElse: () {
              if (data.variants.isNotEmpty) return data.variants.first;
              throw Exception('No variants available for product ${data.id}');
            },
          );
          final card = CustomProductCard(
                productId: data.id,
                productImage: data.mainImage,
                productName: data.title,
                productSlug: data.slug,
                productPrice: defaultVariant.price.toString(),
                specialPrice: defaultVariant.specialPrice.toString(),
                productTags: const [],
                estimatedDeliveryTime: data.estimatedDeliveryTime,
                ratings: double.parse(data.ratings.toString()),
                ratingCount: data.ratingCount,
                isSponsored: data.isSponsored,
                badge: data.badge,
                onCardTap: data.isSponsored
                    ? () => context.read<AdClickBloc>().add(RecordClick(
                          campaignId: data.campaignId,
                          visitorKey: data.visitorKey,
                        ))
                    : null,
                onAddToCart: () {
                  log('Add to Cart Addons ${data.variants.length > 1 || data.variants.any((v) => v.addonGroups.isNotEmpty == true)}');

                  if (data.variants.length > 1 || data.variants.any((v) => v.addonGroups.isNotEmpty == true)) {
                    showVariantBottomSheetWithAddons(
                      variantsList: data.variants,
                      productData: data,
                      productImage: data.mainImage,
                      quantityStepSize: data.quantityStepSize,
                      context: context,
                    );
                  } else {
                    final item = UserCart(
                        productId: data.id.toString(),
                        variantId: defaultVariant.id.toString(),
                        variantName: defaultVariant.title.toString(),
                        vendorId: defaultVariant.storeId.toString(),
                        name: data.title,
                        image: data.mainImage,
                        price: defaultVariant.specialPrice.toDouble(),
                        originalPrice: defaultVariant.price.toDouble(),
                        quantity: data.quantityStepSize,
                        serverCartItemId: null,
                        syncAction: CartSyncAction.add,
                        updatedAt: DateTime.now(),
                        minQty: data.minimumOrderQuantity,
                        maxQty: data.totalAllowedQuantity,
                        isOutOfStock: defaultVariant.stock <= 0,
                        isSynced: false
                    );
                    context.read<CartBloc>().add(AddToCart(item: item, context: context));
                  }
                },
                variantCount: data.variants.length,
                onVariantSelectorRequested: data.variants.length > 1
                    ? () => showVariantBottomSheetWithAddons(
                  variantsList: data.variants,
                  productData: data,
                  productImage: data.mainImage,
                  quantityStepSize: data.quantityStepSize,
                  context: context,
                ) : null,
                isStoreOpen: data.storeStatus?.isOpen ?? true,
                isWishListed: data.favorite.isNotEmpty,
                productVariantId: defaultVariant.id,
                storeId: defaultVariant.storeId,
                wishlistItemId: data.favorite.isNotEmpty ? data.favorite.first.id ?? 0 : 0,
                totalStocks: defaultVariant.stock,
                imageFit: data.imageFit,
                quantityStepSize: data.quantityStepSize,
                minQty: data.minimumOrderQuantity,
                totalAllowedQuantity: data.totalAllowedQuantity,
                indicator: data.indicator,
              );

          final Widget cardWidget =
              data.isSponsored && data.campaignId > 0
                  ? AdVisibilityObserver(
                      campaignId: data.campaignId,
                      visitorKey: data.visitorKey,
                      child: card,
                    )
                  : card;

          return Padding(
            padding: EdgeInsets.only(right: isTablet ? 12.0 : 8.0),
            child: SizedBox(
              width: isTablet ? 75.w : 115.w,
              child: cardWidget,
            ),
          );
        },
      ),
    );
  }
}

Widget buildFeatureSection(FeaturedSectionData section) {
  return ProductFeatureSectionWidget(
    featureSectionData: section,
    featureSectionTitle: '',
    backgroundImage: section.mobileBackgroundImage ?? '',
    backgroundImageTablet: section.tabletBackgroundImage ?? '',
    featureSectionSlug: section.slug ?? '',
    featureSectionStyle: section.style!,
    backgroundColor: section.backgroundColor,
    backgroundType: section.backgroundType,
  );
}