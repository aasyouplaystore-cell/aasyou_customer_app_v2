import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/model/user_cart_model/cart_sync_action.dart';
import 'package:aasyou/model/user_cart_model/user_cart.dart';
import 'package:aasyou/screens/ad_campaign/bloc/ad_click_bloc/ad_click_bloc.dart';
import 'package:aasyou/screens/ad_campaign/widgets/ad_visibility_observer.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_state.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/screens/product_listing_page/model/product_listing_type.dart';
import 'package:aasyou/utils/widgets/bottom_variant_selector_with_addons.dart';
import 'package:aasyou/utils/widgets/custom_product_card.dart';

import 'featured_section_filter.dart';

/// Phase C+D section widget that surfaces every `section_type == "featured"`
/// entry from the existing `FeatureSectionProductBloc`.
///
/// This widget intentionally re-uses the bloc/repo already wired into
/// `home_tab_content_section.dart` - it does not introduce any new API call.
/// All it does is **filter** the loaded sections list down to the ones whose
/// `sectionType` matches the "featured" bucket and render them as a
/// responsive grid of horizontal product cards (capped at 8).
///
/// Visibility rules (mirrors web Featured Products strip):
///   - Hidden entirely when the bloc is not in a loaded state.
///   - Hidden when the filtered list contains zero products.
///
/// Will be wrapped by a `WebSettingsGate` in the D-phase task; this widget
/// itself does not consult `WebSettingsBloc` so it can be reused/tested in
/// isolation.
class HomeFeaturedProductsSection extends StatelessWidget {
  const HomeFeaturedProductsSection({super.key});

  /// `section_type` value emitted by the API for the "featured" bucket.
  static const String _sectionType = 'featured';

  /// Hard cap on rendered products - matches the web Featured strip.
  static const int _maxProducts = 8;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureSectionProductBloc, FeatureSectionProductState>(
      builder: (context, state) {
        if (state is! FeatureSectionProductLoaded) {
          // The umbrella `HomeFeaturedSection` shows the shared loading
          // placeholder/error UI; this per-type section stays silent until
          // data arrives so it doesn't double up skeletons or error states.
          return const SizedBox.shrink();
        }

        final filter = FeaturedSectionTypeFilter.filter(
          sections: state.featureSectionProductData,
          sectionType: _sectionType,
          maxProducts: _maxProducts,
        );

        if (filter.products.isEmpty) {
          return const SizedBox.shrink();
        }

        return _FeaturedProductsGrid(
          title: filter.title,
          slug: filter.slug,
          totalCount: filter.totalCount,
          products: filter.products,
        );
      },
    );
  }
}

class _FeaturedProductsGrid extends StatelessWidget {
  final String title;
  final String slug;
  final int? totalCount;
  final List<ProductData> products;

  const _FeaturedProductsGrid({
    required this.title,
    required this.slug,
    required this.totalCount,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: title,
          slug: slug,
          totalCount: totalCount,
        ),
        SizedBox(height: 6.h),
        FeaturedProductsGridBody(products: products),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String slug;
  final int? totalCount;

  const _SectionHeader({
    required this.title,
    required this.slug,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        left: 10.w,
        right: 10.w,
        top: 10.h,
        bottom: 4.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: slug.isEmpty
                ? null
                : () {
                    GoRouter.of(context).pushNamed(
                      'product-listing',
                      extra: {
                        'isTheirMoreCategory': false,
                        'title': title,
                        'logo': '',
                        'totalProduct': totalCount,
                        'type': ProductListingType.featuredSection,
                        'identifier': slug,
                      },
                    );
                  },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Text(
                l10n?.seeAll ?? 'See All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive grid body shared between the Featured Products and Top Rated
/// sections. Renders horizontal product cards in:
///   - 1 column on phones (<600w)
///   - 2 columns on small tablets / large phones (600-1024w)
///   - 4 columns on desktop-class widths (>=1024w)
class FeaturedProductsGridBody extends StatelessWidget {
  final List<ProductData> products;

  const FeaturedProductsGridBody({super.key, required this.products});

  int _columnsFor(double width) {
    if (width >= 1024) return 4;
    if (width >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final columns = _columnsFor(maxWidth);

        // Horizontal product cards are visually wider than they are tall;
        // tune the aspect ratio per breakpoint so the card content (image +
        // info column + add button) does not overflow at any width.
        final double aspectRatio = switch (columns) {
          4 => 1.55,
          2 => 1.75,
          _ => 2.05,
        };

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) => HomeFeaturedProductTile(
            product: products[index],
          ),
        );
      },
    );
  }
}

/// Single product cell that wires a `ProductData` into a
/// `CustomProductCard(variant: horizontal)` with the same cart / variant /
/// ad-tracking behaviour as the existing `ProductFeatureSectionWidget`
/// horizontal scroller, so the home tab keeps a consistent UX regardless of
/// which strip rendered the card.
class HomeFeaturedProductTile extends StatelessWidget {
  final ProductData product;

  const HomeFeaturedProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final data = product;
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
      variant: ProductCardVariant.horizontal,
      onCardTap: data.isSponsored
          ? () => context.read<AdClickBloc>().add(
                RecordClick(
                  campaignId: data.campaignId,
                  visitorKey: data.visitorKey,
                ),
              )
          : null,
      onAddToCart: () {
        log(
          'Add to Cart Addons '
          '${data.variants.length > 1 || data.variants.any((v) => v.addonGroups.isNotEmpty == true)}',
        );

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
    );

    return data.isSponsored && data.campaignId > 0
        ? AdVisibilityObserver(
            campaignId: data.campaignId,
            visitorKey: data.visitorKey,
            child: card,
          )
        : card;
  }
}
