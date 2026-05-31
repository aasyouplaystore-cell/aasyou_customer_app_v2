import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/helper.dart';
import '../../../../config/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/app_routes.dart';
import '../../../../utils/widgets/custom_image_container.dart';
import '../../../../utils/widgets/custom_shimmer.dart';
import '../../../near_by_stores/bloc/near_by_store/near_by_store_bloc.dart';
import '../../../near_by_stores/model/near_by_store_model.dart';

/// Home tab section showing a horizontal scrolling list of nearby stores.
/// Mirrors [HomeMarketCategoriesSection]'s heading + see-all pattern, but
/// renders compact store cards (logo + name + rating + distance) instead of
/// the full-bleed [StoreCardBanner] used on the dedicated listing screen.
///
/// Mirrors the web `Stores` swiper:
///   - title "Browse Stores" + description "Stores near you"
///   - "See all" link -> /near-by-store (full listing screen)
///   - horizontal scroller of compact cards
///   - hides itself entirely when there are zero items (no skeleton stuck on
///     screen, no broken empty state)
///   - hides itself entirely when the system is single-vendor (parity with
///     [home_page.dart]'s `_refreshApiOnLocationChange` gate)
///   - shows shimmer skeleton while loading
///   - silently hides on failure so a network blip on this strip cannot break
///     the rest of the home tab or interfere with the
///     [FeatureSectionProductFailed] -> NoDeliveryLocationPage cascade
///
/// Mounted as a `SliverToBoxAdapter(child: HomeBrowseStoresSection())` inside
/// `home_tab_content_section.dart`, between [HomeMarketCategoriesSection] and
/// the middle carousel banner. Reads the existing globally-registered
/// `NearByStoreBloc` (see `lib/config/global_bloc_providers.dart`) - no new
/// DI is added by this widget.
class HomeBrowseStoresSection extends StatelessWidget {
  const HomeBrowseStoresSection({super.key});

  static const int _maxItems = 12;
  static const int _skeletonCount = 6;

  /// Card width for the horizontal scroller. Tuned so a typical phone shows
  /// ~1.6 cards and tablets show 3-4, matching the visual rhythm of
  /// [HomeMarketCategoriesSection]'s strip.
  double _cardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 220;
    if (screenWidth >= 800) return 210;
    if (screenWidth >= 600) return 200;
    return 190;
  }

  @override
  Widget build(BuildContext context) {
    // Single-vendor builds don't have a "nearby stores" concept - hide
    // entirely to match the rest of the app's single-vendor handling.
    if (AppHelpers.systemVendorTypeIsSingle) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<NearByStoreBloc, NearByStoreState>(
      builder: (context, state) {
        if (state is NearByStoreLoaded) {
          final stores = state.stores.stores;
          if (stores.isEmpty) {
            // Hide section completely when there are no nearby stores
            // (matches web `shouldHide` behaviour).
            return const SizedBox.shrink();
          }
          return _LoadedSection(
            stores: stores,
            cardWidth: _cardWidth(context),
            maxItems: _maxItems,
          );
        }

        if (state is NearByStoreLoading || state is NearByStoreInitial) {
          return _LoadingSection(
            cardWidth: _cardWidth(context),
            skeletonCount: _skeletonCount,
          );
        }

        // NearByStoreFailed (or anything else) -> silently hide so a network
        // blip on this section doesn't break the rest of the home tab and
        // cannot interfere with the FeatureSectionProductFailed ->
        // NoDeliveryLocationPage cascade in home_tab_content_section.dart.
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadedSection extends StatelessWidget {
  final List<StoreData> stores;
  final double cardWidth;
  final int maxItems;

  const _LoadedSection({
    required this.stores,
    required this.cardWidth,
    required this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final visible =
        stores.length > maxItems ? stores.sublist(0, maxItems) : stores;

    // Compact card: small banner top + logo + name + rating/distance row.
    // ~190 tall with a little vertical padding buffer.
    final listHeight = 190.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            itemCount: visible.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final item = visible[index];
              return SizedBox(
                width: cardWidth,
                child: _HomeStoreStripCard(
                  store: item,
                  onTap: () => _openDetail(context, item),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  void _openDetail(BuildContext context, StoreData item) {
    final slug = item.slug;
    if (slug == null || slug.isEmpty) return;
    GoRouter.of(context).push(
      AppRoutes.nearbyStoreDetails,
      extra: {
        'store-slug': slug,
        'store-name': item.name,
      },
    );
  }
}

class _LoadingSection extends StatelessWidget {
  final double cardWidth;
  final int skeletonCount;

  const _LoadingSection({
    required this.cardWidth,
    required this.skeletonCount,
  });

  @override
  Widget build(BuildContext context) {
    final listHeight = 190.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading shimmer (same shape/size as the real heading) so the layout
        // doesn't jump when data lands.
        Padding(
          padding: EdgeInsets.only(
            left: 10.w,
            right: 10.w,
            top: 10.h,
            bottom: 10.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget.rectangular(
                isBorder: true,
                height: 18,
                width: 180,
                borderRadius: 8,
              ),
              ShimmerWidget.rectangular(
                isBorder: true,
                height: 14,
                width: 50,
                borderRadius: 6,
              ),
            ],
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            itemCount: skeletonCount,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              return SizedBox(
                width: cardWidth,
                child: const HomeStoreStripCardSkeleton(),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 10.w,
        right: 10.w,
        top: 10.h,
        bottom: 6.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // Prefer a dedicated `browseStores` key when available;
                  // fall back to the existing `nearbyStores` localisation so
                  // this section ships translated in all 6 supported locales
                  // even before a new .arb key is added.
                  _resolveTitle(l10n),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Stores near you',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.70),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () => GoRouter.of(context).push(AppRoutes.nearbyStores),
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

  /// Resolve the heading using `l10n.browseStores` when the generated
  /// localisations expose it, otherwise the already-localised
  /// `l10n.nearbyStores`, otherwise the English default. Uses a dynamic
  /// lookup so the section compiles even if `browseStores` has not yet been
  /// added to the .arb files.
  String _resolveTitle(AppLocalizations? l10n) {
    if (l10n == null) return 'Browse Stores';
    try {
      final dynamic dyn = l10n;
      final value = dyn.browseStores;
      if (value is String && value.isNotEmpty) return value;
    } catch (_) {
      // Key not generated yet - fall through to the localised fallback.
    }
    return l10n.nearbyStores;
  }
}

/// Compact horizontal-strip store card. Modelled on the rhythm of
/// `CustomMarketCategoryCard` / `CustomBrandsCard` so the Browse Stores
/// strip sits visually alongside the other home strips. Deliberately not
/// reusing the full-width [StoreCardBanner] from the listing screen because
/// that card is hard-coded for `width: double.infinity`, 120-tall banner,
/// 90x90 overhanging logo and ~240 total height - far too bloated for a
/// horizontal home strip.
class _HomeStoreStripCard extends StatelessWidget {
  final StoreData store;
  final VoidCallback? onTap;

  const _HomeStoreStripCard({
    required this.store,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double distance = store.distance ?? 0.0;
    final double rating =
        double.tryParse(store.avgStoreRating ?? '0.0') ?? 0.0;

    return Material(
      color: theme.colorScheme.onPrimary,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ------------------- Compact banner + logo -------------------
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: store.banner?.isNotEmpty == true
                        ? CustomImageContainer(
                            imagePath: store.banner!,
                            fit: BoxFit.cover,
                          )
                        : _gradientPlaceholder(),
                  ),
                  PositionedDirectional(
                    start: 10,
                    bottom: -18,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: store.logo?.isNotEmpty == true
                            ? CustomImageContainer(
                                imagePath: store.logo!,
                                fit: BoxFit.cover,
                              )
                            : _iconPlaceholder(),
                      ),
                    ),
                  ),
                ],
              ),

              // Spacer for the overhanging logo.
              const SizedBox(height: 24),

              // ------------------- Store info -------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      store.name ?? 'Unknown Store',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          AppTheme.ratingStarIconFilled,
                          size: 12,
                          color: AppTheme.ratingStarColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradientPlaceholder() => Container(
        decoration: const BoxDecoration(color: AppTheme.primaryColor),
        child: const Center(
          child: Icon(Icons.store, size: 28, color: Colors.white70),
        ),
      );

  Widget _iconPlaceholder() => Container(
        color: Colors.blue.shade50,
        child: const Icon(Icons.store, size: 20, color: AppTheme.primaryColor),
      );
}

/// Skeleton for a single home-strip store card while data is loading.
/// Exported so other surfaces can reuse it if needed (mirrors the
/// [MarketCategoryCardSkeleton] export pattern).
class HomeStoreStripCardSkeleton extends StatelessWidget {
  const HomeStoreStripCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget.rectangular(
      isBorder: true,
      height: double.infinity,
      width: double.infinity,
      borderRadius: 12,
    );
  }
}
