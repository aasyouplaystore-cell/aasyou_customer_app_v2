import 'package:flutter/material.dart' as material show Badge;
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/home_page/widgets/sections/home_top_address_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:aasyou/screens/store_follow/bloc/store_follow_bloc.dart';
import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/settings_data_instance.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/utils/widgets/custom_shimmer.dart';
import 'package:aasyou/utils/widgets/custom_sorting_bottom_sheet.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';
import 'package:aasyou/utils/widgets/empty_states_page.dart';
import 'package:remixicon/remixicon.dart';
import '../../../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../../../bloc/user_cart_bloc/user_cart_event.dart';
import '../../../bloc/user_cart_bloc/user_cart_state.dart';
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
        actions: [
          _buildCartAction(),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade300, height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildCartAction() {
    return IconButton(
      tooltip: 'Cart',
      onPressed: () => GoRouter.of(context).push(AppRoutes.cart),
      icon: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int itemCount = 0;
          if (state is CartLoaded) {
            itemCount = state.totalItems;
          }
          return material.Badge(
            isLabelVisible: itemCount > 0,
            label: Text(
              itemCount > 9 ? '9+' : itemCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
            backgroundColor: Colors.red.shade600,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              HeroiconsOutline.shoppingCart,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          );
        },
      ),
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

  /// Non-blocking notice for browse-only shared store links: the viewer's
  /// location is outside this store's delivery zones. Store + catalog stay
  /// viewable (grid falls back to the location-free store-wise API).
  Widget _buildDeliveryUnavailableBanner() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off_outlined, color: scheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.deliveryNotAvailableAtThisLocation,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: scheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () => showHomeLocationBottomSheet(context),
            child: Text(
              l10n.changeLocation,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(StoreData store) {
    // Seed the Shop-Follow controller with the server snapshot so the
    // header heart and follower count stay in sync with every other card
    // (popular shop strip, listing banner, map popup, browse strip).
    final int? storeId = store.id;
    if (storeId != null) {
      StoreFollowController.instance.seedFromStore(
        storeId: storeId,
        isFollowed: store.isFollowed,
        followersCount: store.followersCount,
      );
    }

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
            // Browse-only shared link: viewer's location is outside this
            // store's delivery zones — page stays viewable, ordering gated.
            if (store.sameLocation == false) _buildDeliveryUnavailableBanner(),
            _buildStoreHero(
              store,
              store.avgStoreRating ?? '0.0',
              store.totalStoreFeedback ?? 0,
            ),
            const SizedBox(height: 12),
            _buildActionButtonsRow(store),
            const SizedBox(height: 14),
            Container(
              height: 5,
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            const SizedBox(height: 10),
            BlocBuilder<ProductListingBloc, ProductListingState>(
              builder: (context, state) => _buildProductsSection(state),
            ),
          ],
        ),
      ),
    );
  }

  /// Mockup-style hero: banner with "Open Now" pill, then a floating white
  /// card overlapping the bottom of the banner with logo / name / location /
  /// rating + product count, and the Follow button on the right edge.
  Widget _buildStoreHero(
    StoreData store,
    String rating,
    int totalStoreFeedback,
  ) {
    final bool isOpen = store.status?.isOpen == true;
    final double bannerHeight = isTablet(context) ? 260 : 180;
    final double doubleRating = double.tryParse(rating) ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner image — rounded bottom corners to feel like a card.
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            height: bannerHeight,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: store.banner?.isNotEmpty == true
                ? CustomImageContainer(
                    imagePath: store.banner!,
                    fit: BoxFit.contain,
                    memCacheWidth: 1200,
                  )
                : Container(
                    decoration: const BoxDecoration(color: AppTheme.primaryColor),
                    child: const Center(
                      child: Icon(Icons.store, size: 50, color: Colors.white70),
                    ),
                  ),
          ),
        ),

        // "Open Now" / "Closed" pill — top-left overlay.
        PositionedDirectional(
          top: 12,
          start: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOpen ? 'Open Now' : 'Closed',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (store.isRecommended ?? false)
          const PositionedDirectional(
            top: 12,
            end: 16,
            child: RecommendBadge(),
          ),

        // Floating info card overlapping the bottom of the banner.
        Positioned(
          left: 12,
          right: 12,
          bottom: -56,
          child: _buildStoreInfoCard(
            store,
            doubleRating,
            totalStoreFeedback,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfoCard(
    StoreData store,
    double rating,
    int totalStoreFeedback,
  ) {
    final int? storeId = store.id;
    final int productCount = store.productCount ?? 0;
    final String productCountLabel =
        productCount >= 120 ? '120+ Products' : '$productCount Products';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: store.logo?.isNotEmpty == true
                  ? CustomImageContainer(
                      imagePath: store.logo!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.blue.shade50,
                      child: const Icon(
                        Icons.store,
                        size: 28,
                        color: AppTheme.primaryColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name ?? 'Unknown Store',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F1F1F),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                if ((store.address ?? '').isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xFF7A7A7A),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          store.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF7A7A7A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      AppTheme.ratingStarIconFilled,
                      size: 14,
                      color: AppTheme.ratingStarColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${rating.toStringAsFixed(1)} ($totalStoreFeedback Reviews)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 12,
                      color: const Color(0xFFE0E0E0),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 13,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        productCountLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Follow button — white pill with heart, mirroring the mockup.
          if (storeId != null)
            _MockupFollowButton(
              storeId: storeId,
              fallbackIsFollowed: store.isFollowed ?? false,
              fallbackFollowersCount: store.followersCount ?? 0,
            ),
        ],
      ),
    );
  }

  /// Row of 3 pill-shaped action buttons: Directions, Share, Call.
  /// Lives below the floating info card.
  Widget _buildActionButtonsRow(StoreData store) {
    final String? lat = store.latitude;
    final String? lng = store.longitude;
    final String? phone = store.contactNumber;
    final String? slug = store.slug;
    final String storeName = store.name ?? 'Store';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 56, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: _ActionPillButton(
              icon: Icons.directions_outlined,
              label: 'Directions',
              color: AppTheme.primaryColor,
              onTap: (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty)
                  ? () => _openDirections(lat, lng, storeName)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionPillButton(
              icon: Icons.share_outlined,
              label: 'Share',
              color: AppTheme.primaryColor,
              onTap: () => _shareStore(storeName, slug),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionPillButton(
              icon: Icons.phone_outlined,
              label: 'Call',
              color: AppTheme.primaryColor,
              onTap: (phone != null && phone.isNotEmpty)
                  ? () => _callStore(phone)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDirections(String lat, String lng, String label) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callStore(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri);
  }

  Future<void> _shareStore(String storeName, String? slug) async {
    // Domain + path BOTH dynamic from backend settings (admin → System →
    // Web). Path is a template with {slug}; if backend hasn't been updated
    // with `storeSharePath`, model default '/stores/{slug}' is used.
    final web = SettingsData.instance.web;
    final raw = web?.customerWebUrl ?? 'https://aasyou.com';
    final base = raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
    final tpl = web?.storeSharePath ?? '/stores/{slug}';
    // Strip trailing /{slug} segment if slug is missing (so we don't share
    // a URL ending in literal "{slug}").
    final path = (slug != null && slug.isNotEmpty)
        ? tpl.replaceAll('{slug}', slug)
        : tpl.replaceAll(RegExp(r'/?\{slug\}.*$'), '');
    final String shareUrl = '$base$path';
    await SharePlus.instance.share(
      ShareParams(
        text: 'Check out $storeName on AasYou — $shareUrl',
        subject: storeName,
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
          crossAxisCount: isTablet(context) ? 3 : 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.74,
          // Sized for the storeGrid card layout: image + name + price + Add button.
          mainAxisExtent: 250.h,
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
      variant: ProductCardVariant.storeGrid,
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

/// White-pill "Follow"/"Following" button matching the mockup. Wraps the
/// shared [StoreFollowController] toggle flow used everywhere else so the
/// header stays in sync with every other heart on the app.
class _MockupFollowButton extends StatelessWidget {
  final int storeId;
  final bool fallbackIsFollowed;
  final int fallbackFollowersCount;

  const _MockupFollowButton({
    required this.storeId,
    required this.fallbackIsFollowed,
    required this.fallbackFollowersCount,
  });

  Future<void> _handleTap(BuildContext context) async {
    if (Global.userData == null) {
      GoRouter.of(context).push(AppRoutes.login);
      return;
    }
    try {
      await StoreFollowController.instance.toggle(storeId);
    } on ApiException catch (e) {
      if (context.mounted) {
        ToastManager.show(context: context, message: e.errorMessage);
      }
    } catch (e) {
      if (context.mounted) {
        ToastManager.show(context: context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoreFollowController.instance;
    return ListenableBuilder(
      listenable: controller.listenableFor(storeId),
      builder: (context, _) {
        final state = controller.stateOf(storeId);
        final bool isFollowed = state?.isFollowed ?? fallbackIsFollowed;
        final bool isPending = state?.isPending ?? false;
        final Color border = isFollowed
            ? AppTheme.primaryColor
            : const Color(0xFFE5E5E5);
        final Color bg = isFollowed
            ? AppTheme.primaryColor.withValues(alpha: 0.08)
            : Colors.white;

        return Material(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: isPending ? null : () => _handleTap(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: border, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFollowed ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isFollowed ? 'Following' : 'Follow',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pill-shaped button used in the Directions / Share / Call action row.
class _ActionPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionPillButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color tint = enabled ? color : color.withValues(alpha: 0.4);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: tint),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: tint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
