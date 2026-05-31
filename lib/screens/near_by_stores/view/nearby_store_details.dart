import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/model/sorting_model/sorting_model.dart';
import 'package:aasyou/screens/near_by_stores/bloc/store_detail/store_detail_bloc.dart';
import 'package:aasyou/screens/near_by_stores/model/near_by_store_model.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/screens/product_listing_page/bloc/filter/filter_bloc.dart';
import 'package:aasyou/screens/product_listing_page/bloc/filter/filter_event.dart';
import 'package:aasyou/screens/product_listing_page/bloc/product_listing/product_listing_bloc.dart';
import 'package:aasyou/screens/product_listing_page/model/product_listing_type.dart';
import 'package:aasyou/screens/product_listing_page/widgets/custom_filter_sort_btn_widget.dart';
import 'package:aasyou/utils/widgets/bottom_variant_selector_with_addons.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import 'package:aasyou/utils/widgets/custom_product_card.dart';
import 'package:aasyou/utils/widgets/recommend_badge.dart';
import 'package:aasyou/utils/widgets/custom_refresh_indicator.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/utils/widgets/custom_shimmer.dart';
import 'package:aasyou/utils/widgets/custom_sorting_bottom_sheet.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';
import 'package:aasyou/utils/widgets/empty_states_page.dart';
import 'package:remixicon/remixicon.dart';
import '../../../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../../../bloc/user_cart_bloc/user_cart_event.dart';
import '../../../config/helper.dart';
import '../../../model/user_cart_model/cart_sync_action.dart';
import '../../../model/user_cart_model/user_cart.dart';
import '../../../utils/widgets/custom_filter_bottom_sheet.dart';
import '../../ad_campaign/bloc/ad_click_bloc/ad_click_bloc.dart';
import '../../ad_campaign/widgets/ad_visibility_observer.dart';

class NearbyStoreDetails extends StatelessWidget {
  final String storeSlug;
  final String storeName;

  const NearbyStoreDetails({
    super.key,
    required this.storeSlug,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => StoreDetailBloc()
            ..add(FetchStoreDetail(storeSlug: storeSlug)),
        ),
        BlocProvider(
          create: (_) => ProductListingBloc()
            ..add(
              FetchListingProducts(
                type: ProductListingType.store,
                storeSlug: storeSlug,
                identifier: storeSlug,
              ),
            ),
        ),
      ],
      child: _NearbyStoreDetailsView(
        storeSlug: storeSlug,
        storeName: storeName,
      ),
    );
  }
}

class _NearbyStoreDetailsView extends StatefulWidget {
  final String storeSlug;
  final String storeName;

  const _NearbyStoreDetailsView({
    required this.storeSlug,
    required this.storeName,
  });

  @override
  State<_NearbyStoreDetailsView> createState() => _NearbyStoreDetailsState();
}

class _NearbyStoreDetailsState extends State<_NearbyStoreDetailsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isSearchInStore = false;
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    context.read<FilterBloc>().add(ClearAllFilters());
  }

  void _showFilterBottomSheet({
    required List<int> categoryIds,
    required List<int> brandsIds
  }) {

    CustomFilterBottomSheet.show(
      context: context,
      listingType: ProductListingType.store,
      categoryIds: categoryIds,
      brandsIds: brandsIds,
      value: widget.storeSlug,
      onApplyFilters: (category, brands, attribute) {
        final categorySlugs = category.map((e) => e.slug ?? '').toList();
        final brandSlugs = brands.map((e) => e.slug ?? '').toList();
        final attributeIds = attribute.map((e) => e.id!).toList();
        context.read<ProductListingBloc>().add(FetchFilteredListingProducts(
          type: ProductListingType.store,
          identifier: widget.storeSlug,
          categorySlugs: categorySlugs,
          brandSlugs: brandSlugs,
          attributeIds: attributeIds,
        ));
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ProductListingBloc>().state;
      if (state is ProductListingLoaded && !state.hasReachedMax) {
        context.read<ProductListingBloc>().add(
          FetchMoreListingProducts(
            type: ProductListingType.store,
            storeSlug: widget.storeSlug,
            identifier: _searchController.text.trim(),
            isSearchInStore: isSearchInStore,
          ),
        );
      }
    }
  }

  void _applySorting(SortOption sortOption) {
    context.read<ProductListingBloc>().add(
      FetchSortedListingProducts(
        type: ProductListingType.store,
        storeSlug: widget.storeSlug,
        identifier: _searchController.text.trim(),
        sortType: sortOption.apiValue,
        isSearchInStore: isSearchInStore,
      ),
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    isSearchInStore = query.isNotEmpty;

    context.read<ProductListingBloc>().add(
      FetchListingProducts(
        type: ProductListingType.store,
        storeSlug: widget.storeSlug,
        identifier: query,
        isSearchInStore: isSearchInStore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        elevation: 0,
        title: _buildSearchBar(),
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade300, height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      margin: const EdgeInsetsGeometry.directional(end: 12),
      child: CustomTextFormField(
        controller: _searchController,
        hintText: 'Search in ${widget.storeName}',

        suffixIcon: _searchController.text.isNotEmpty ? Icons.close : Icons.search,
        onSuffixIconTap: () {
          setState(() {
            if (isSubmitted) {
              isSubmitted = false;
              isSearchInStore = false;
              _searchController.clear();
              _performSearch();
            } else if (_searchController.text.isNotEmpty) {
              isSearchInStore = true;
              isSubmitted = true;
              _performSearch();
            }
          });
          FocusScope.of(context).unfocus();
        },
        onFieldSubmitted: (_) {
          setState(() {
            isSearchInStore = _searchController.text.trim().isNotEmpty;
            isSubmitted = true;
          });
          _performSearch();
        },
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<StoreDetailBloc, StoreDetailState>(
      listener: (context, state) {},
      builder: (context, storeState) {
        if (storeState is StoreDetailLoading) {
          return const CustomCircularProgressIndicator();
        }
        if (storeState is StoreDetailFailed) {
          return NoProductPage(onRetry: _performSearch);
        }
        if (storeState is StoreDetailLoaded) {
          return _buildScrollableContent(storeState.storeData);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildScrollableContent(StoreData store) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        context.read<ProductListingBloc>().add(
          FetchMoreListingProducts(
            type: ProductListingType.store,
            storeSlug: widget.storeSlug,
            identifier: _searchController.text.trim(),
            isSearchInStore: isSearchInStore,
          ),
        );
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreHeader(store, store.distance ?? 0.0, store.avgStoreRating ?? '0.0', store.totalStoreFeedback!),
            const SizedBox(height: 68),
            _buildStoreInfo(store, store.distance ?? 0.0),
            Container(
              height: 5,
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            const SizedBox(height: 10,),
            BlocBuilder<ProductListingBloc, ProductListingState>(
              builder: (context, state) => _buildProductsSection(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader(StoreData store, double distance, String rating, int totalStoreFeedback) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          child: Container(
            height: isTablet(context) ? 280 : 170,
            width: double.infinity,
            color: Colors.grey[200],
            child: store.banner?.isNotEmpty == true
                ? CustomImageContainer(imagePath: store.banner!, fit: BoxFit.cover)
                : Container(
              decoration: const BoxDecoration(color: AppTheme.primaryColor),
              child: const Center(
                child: Icon(Icons.store, size: 50, color: Colors.white70),
              ),
            ),
          ),
        ),
        if (store.isRecommended ?? false)
          const PositionedDirectional(
            top: 12,
            start: 12,
            child: RecommendBadge(),
          ),
        PositionedDirectional(
          start: 16,
          bottom: -60,
          child: Container(
            width: isTablet(context) ? 120 : 90,
            height: isTablet(context) ? 120 : 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: store.logo?.isNotEmpty == true
                  ? CustomImageContainer(imagePath: store.logo!, fit: BoxFit.cover)
                  : Container(
                color: Colors.blue.shade50,
                child: const Icon(Icons.store, size: 28, color: AppTheme.primaryColor),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          end: 12,
          bottom: -40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppTheme.ratingStarIconFilled, size: 16, color: AppTheme.ratingStarColor),
                const SizedBox(width: 4),
                Text('$rating/5 ($totalStoreFeedback)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfo(StoreData store, double distance) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(store.name ?? "Unknown Store",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(child: Text(store.address ?? "No address", style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text('${distance.toStringAsFixed(1)} km',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: store.status?.isOpen == true ? 'Open Now' : 'Closed',
                        style: TextStyle(fontSize: 13, color: store.status?.isOpen == true ? Colors.green : Colors.red),
                      ),
                      if (store.timing != null && store.timing!.isNotEmpty)
                        TextSpan(text: ' · ${store.timing}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildProductsSection(ProductListingState state) {
    if (state is ProductListingFailed) {
      return SizedBox(
        height: isTablet(context) ? 1000 : 500,
        child: const Center(child: NoProductPage())
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 10),
          if(state is ProductListingLoaded)
            Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: Row(
              children: [
                CustomFilterSortBtnWidget(
                  onTap: () => _showFilterBottomSheet(
                      categoryIds: state.categoryIds ?? [],
                      brandsIds: state.brandIds ?? []
                  ),
                  buttonName: 'Filter',
                  iconData: RemixIcons.equalizer_3_line,
                ),
                const SizedBox(width: 10),
                CustomFilterSortBtnWidget(
                  onTap: _showSortBottomSheet,
                  buttonName: 'Sort',
                  iconData: HeroiconsOutline.arrowsUpDown,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (state is ProductListingLoading) SizedBox(height: isTablet(context) ? 1000 : 500, child: const Center(child: CustomCircularProgressIndicator())),
          if (state is ProductListingLoaded)
            _buildProductContent(state.productList, state.isFilterLoading, state.hasReachedMax),
        ],
      ),
    );
  }

  Widget _buildProductContent(List<ProductData> productData, bool isFilterLoading, bool hasReachedMax) {
    if (isFilterLoading) {
      return SizedBox(height: isTablet(context) ? 1000 : 500, child: const Center(child: CustomCircularProgressIndicator()));
    }
    if (productData.isEmpty) {
      return NoProductPage(onRetry: _performSearch);
    }
    return _buildProductGrid(productData, hasReachedMax);
  }

  Widget _buildProductGrid(List<ProductData> productData, bool hasReachedMax) {
    return Padding(
      padding: EdgeInsets.only(left: 14.w, right: 7.w, top: 8.h, bottom: 8.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet(context) ? 4 : 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 0.75,
          // +22.h to leave room for the "Recommended" chip in the card.
          mainAxisExtent: 234.h,
        ),
        itemCount: hasReachedMax ? productData.length : productData.length + 3,
        itemBuilder: (context, index) => _buildGridItem(productData, index, hasReachedMax),
      ),
    );
  }

  Widget _buildGridItem(List<ProductData> productData, int index, bool hasReachedMax) {
    if (index >= productData.length) return productShimmer();
    final product = productData[index];
    final variant = product.variants.isNotEmpty ? product.variants.first : ProductVariants();

    final card = CustomProductCard(
      productId: product.id,
      productImage: product.mainImage,
      productName: product.title,
      productSlug: product.slug,
      productPrice: variant.price.toString(),
      specialPrice: variant.specialPrice.toString(),
      productTags: const [],
      estimatedDeliveryTime: product.estimatedDeliveryTime,
      ratings: product.ratings.toDouble(),
      ratingCount: product.ratingCount,
      isSponsored: product.isSponsored,
      onCardTap: product.isSponsored
          ? () => context.read<AdClickBloc>().add(RecordClick(
                campaignId: product.campaignId,
                visitorKey: product.visitorKey,
              ))
          : null,
      onAddToCart: () {
        if (product.variants.length > 1 || product.variants.any((v) => v.addonGroups.isNotEmpty == true)) {
          showVariantBottomSheetWithAddons(
            variantsList: product.variants,
            productData: product,
            productImage: product.mainImage,
            quantityStepSize: product.quantityStepSize,
            context: context,
          );
        } else {
          final item = UserCart(
              productId: product.id.toString(),
              variantId: product.variants.firstWhere((variant) => variant.isDefault).id.toString(),
              variantName: product.variants.firstWhere((variant) => variant.isDefault).title.toString(),
              vendorId: product.variants.firstWhere((variant) => variant.isDefault).storeId.toString(),
              name: product.title,
              image: product.mainImage,
              price: product.variants.firstWhere((variant) => variant.isDefault).specialPrice.toDouble(),
              originalPrice: product.variants.firstWhere((variant) => variant.isDefault).price.toDouble(),
              quantity: product.quantityStepSize,
              serverCartItemId: null,
              syncAction: CartSyncAction.add,
              updatedAt: DateTime.now(),
              minQty: product.minimumOrderQuantity,
              maxQty: product.totalAllowedQuantity,
              isOutOfStock: product.variants.firstWhere((variant) => variant.isDefault).stock <= 0,
              isSynced: false
          );
          context.read<CartBloc>().add(AddToCart(item: item, context:  context));

          // context.read<AddToCartBloc>().add(
        }
      },
      variantCount: product.variants.length,
      onVariantSelectorRequested: product.variants.length > 1
          ? () => showVariantBottomSheetWithAddons(
        variantsList: product.variants,
        productData: product,
        productImage: product.mainImage,
        quantityStepSize: product.quantityStepSize,
        context: context,
      )
          : null,
      isStoreOpen: product.storeStatus?.isOpen ?? true,
      isWishListed: product.favorite.isNotEmpty,
      productVariantId: variant.id,
      storeId: variant.storeId,
      wishlistItemId: product.favorite.isNotEmpty ? product.favorite.first.id ?? 0 : 0,
      totalStocks: variant.stock,
      imageFit: product.imageFit,
      quantityStepSize: product.quantityStepSize,
      minQty: product.minimumOrderQuantity,
      totalAllowedQuantity: product.totalAllowedQuantity,
      badge: product.badge,
    );

    if (product.isSponsored && product.campaignId > 0) {
      return AdVisibilityObserver(
        campaignId: product.campaignId,
        visitorKey: product.visitorKey,
        child: card,
      );
    }

    return card;
  }

  Widget productShimmer() {
    return Column(
      children: [
        ShimmerWidget.rectangular(height: 130, width: 130, borderRadius: 15, isBorder: true,),
        const SizedBox(height: 10),
        ShimmerWidget.rectangular(isBorder: false, height: 15, width: 130, borderRadius: 15),
      ],
    );
  }

  void _showSortBottomSheet() {
    final currentState = context.read<ProductListingBloc>().state;
    final currentSortType = currentState is ProductListingLoaded ? currentState.currentSortType : SortType.relevance;

    CustomSortBottomSheet.show(
      context: context,
      currentSortType: currentSortType,
      onSortSelected: _applySorting,
      isFromStore: true
    );
  }
}
