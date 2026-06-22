import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/model/user_cart_model/cart_sync_action.dart';
import 'package:aasyou/model/user_cart_model/user_cart.dart';
import 'package:aasyou/screens/ad_campaign/bloc/ad_click_bloc/ad_click_bloc.dart';
import 'package:aasyou/screens/ad_campaign/widgets/ad_visibility_observer.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_state.dart';
import 'package:aasyou/screens/home_page/model/featured_section_product_model.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/screens/product_listing_page/model/product_listing_type.dart';
import 'package:aasyou/utils/widgets/bottom_variant_selector_with_addons.dart';
import 'package:aasyou/utils/widgets/custom_product_card.dart';

/// HomeMangoManiaSection
/// ─────────────────────
/// Renders the "Newly Added" featured section (section_type == 'newly_added')
/// as a banner-as-background hero block with a horizontal product grid
/// overlaid on top.
///
/// Source:
///   Reads [FeatureSectionProductBloc] state and picks the first
///   [FeaturedSectionData] whose `sectionType == 'newly_added'`. If the
///   bloc has not produced a Loaded state yet, or no newly_added row exists,
///   the section renders `SizedBox.shrink()` so it never blocks the rest of
///   the home page.
///
/// Background fallback chain (web parity):
///   desktop_fdh_background_image → desktop_4k_background_image →
///   tablet_background_image → mobile_background_image → background_image
///   (the model exposes background variants but no top-level "banner" /
///   "backgroundImage" field, so the chain falls through to whatever the
///   server populated and the section auto-hides if all are empty AND no
///   background_color is set).
///
/// Auto-hide:
///   The section returns `SizedBox.shrink()` when:
///     • the bloc is not in Loaded state, OR
///     • no row with sectionType == 'newly_added' exists, OR
///     • the row has no products, OR
///     • the row has no resolvable banner image AND no background_color.
class HomeMangoManiaSection extends StatelessWidget {
  const HomeMangoManiaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureSectionProductBloc, FeatureSectionProductState>(
      builder: (context, state) {
        if (state is! FeatureSectionProductLoaded) {
          return const SizedBox.shrink();
        }

        FeaturedSectionData? section;
        for (final s in state.featureSectionProductData) {
          if ((s.sectionType ?? '').toLowerCase() == 'newly_added') {
            section = s;
            break;
          }
        }

        if (section == null || section.products.isEmpty) {
          return const SizedBox.shrink();
        }

        final bgUrl = _resolveBackgroundImage(section);
        final hasBgImage = bgUrl.isNotEmpty;
        final bgColor = hexStringToColor(section.backgroundColor);
        final isColorBg =
            (section.backgroundType ?? '').toLowerCase() == 'color' &&
                bgColor != null;

        // Section auto-hides if no banner image AND no background_color.
        if (!hasBgImage && !isColorBg) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: _MangoManiaBody(
              section: section,
              backgroundUrl: bgUrl,
              backgroundColor: isColorBg ? bgColor : null,
              useImage: hasBgImage,
            ),
          ),
        );
      },
    );
  }

  /// Web parity responsive fallback chain:
  /// desktop_fdh → desktop_4k → tablet → mobile.
  static String _resolveBackgroundImage(FeaturedSectionData s) {
    final candidates = <String?>[
      s.desktopFdhBackgroundImage,
      s.desktop4kBackgroundImage,
      s.tabletBackgroundImage,
      s.mobileBackgroundImage,
    ];
    for (final c in candidates) {
      if (c != null && c.trim().isNotEmpty) return c;
    }
    return '';
  }
}

class _MangoManiaBody extends StatelessWidget {
  final FeaturedSectionData section;
  final String backgroundUrl;
  final Color? backgroundColor;
  final bool useImage;

  const _MangoManiaBody({
    required this.section,
    required this.backgroundUrl,
    required this.backgroundColor,
    required this.useImage,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // 1 col phone (<600w), 2 cols tablet (600-1024w), 4 cols desktop (>=1024w).
    final int crossAxisCount = width >= 1024
        ? 4
        : width >= 600
            ? 2
            : 1;

    // Cap to 8 products.
    final products = section.products.length > 8
        ? section.products.sublist(0, 8)
        : section.products;

    return Stack(
      children: [
        // ── Background layer ─────────────────────────────────────────────
        Positioned.fill(
          child: useImage
              ? CachedNetworkImage(
                  imageUrl: backgroundUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: backgroundColor ?? Colors.transparent,
                  ),
                )
              : Container(color: backgroundColor ?? Colors.transparent),
        ),

        // ── Foreground ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  _SeeAllPill(section: section),
                ],
              ),
              SizedBox(height: 12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  // Horizontal cards are wider than tall; tune ratio per layout.
                  childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.8,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemBuilder: (context, index) =>
                    _buildProductCard(context, products[index]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ProductData data) {
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
        log('MangoMania Add to Cart productId=${data.id}');
        if (data.variants.length > 1 ||
            data.variants.any((v) => v.addonGroups.isNotEmpty == true)) {
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
            isSynced: false,
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
              )
          : null,
      isStoreOpen: data.storeStatus?.isOpen ?? true,
      isWishListed: data.favorite.isNotEmpty,
      productVariantId: defaultVariant.id,
      storeId: defaultVariant.storeId,
      wishlistItemId:
          data.favorite.isNotEmpty ? data.favorite.first.id ?? 0 : 0,
      totalStocks: defaultVariant.stock,
      imageFit: data.imageFit,
      quantityStepSize: data.quantityStepSize,
      minQty: data.minimumOrderQuantity,
      totalAllowedQuantity: data.totalAllowedQuantity,
      indicator: data.indicator,
      variant: ProductCardVariant.horizontal,
    );

    if (data.isSponsored && data.campaignId > 0) {
      return AdVisibilityObserver(
        campaignId: data.campaignId,
        visitorKey: data.visitorKey,
        child: card,
      );
    }
    return card;
  }
}

/// Small white rounded pill that links to the section detail
/// (`product-listing` route, identifier = section slug,
/// type = ProductListingType.featuredSection).
class _SeeAllPill extends StatelessWidget {
  final FeaturedSectionData section;
  const _SeeAllPill({required this.section});

  @override
  Widget build(BuildContext context) {
    final title = section.title ?? '';
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () {
        GoRouter.of(context).pushNamed(
          'product-listing',
          extra: {
            'isTheirMoreCategory': false,
            'title': title,
            'logo': '',
            'totalProduct': section.productsCount,
            'type': ProductListingType.featuredSection,
            'identifier': section.slug ?? '',
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          AppLocalizations.of(context)!.seeAll,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
