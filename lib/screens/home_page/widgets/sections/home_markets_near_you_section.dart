import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../router/app_routes.dart';
import '../../../../utils/widgets/cache_manager.dart';
import '../../../../utils/widgets/custom_shimmer.dart';
import '../../../near_by_stores/model/near_by_store_model.dart';
import '../../bloc/market_category/market_category_bloc.dart';
import '../../bloc/market_category/market_category_state.dart';
import '../../model/market_category_model.dart';
import '../../repo/market_category_repo.dart';

/// Home tab section: "Markets Near You".
///
/// Reuses the globally-registered [HomeMarketCategoriesBloc] (which already
/// loads all market_categories including children) and filters down to the
/// child markets (`parentId != null`). For each child market we additionally
/// fan out a single `/delivery-zone/stores?market_category_slug=<slug>` call
/// to derive the live `isOpen` flag and the nearest store distance — a
/// deliberate client-side N+1 (Phase C/D default locked decision: N is
/// expected to be tiny, currently a single child market "Raisar Plaza").
///
/// Card visual (per Phase C/D spec):
///   * Fixed width 180, AspectRatio 4/5, Stack:
///     - full-bleed `market.image` background (CachedNetworkImage)
///     - dark gradient overlay (top→bottom, transparent → black54)
///     - top-end pill: green "Open" or grey "Closed"
///     - bottom-start: bold white market name + pin icon row with
///       nearest distance ("X.X km", white70)
///
/// Renders a `ListView.builder` (horizontal). Hides itself entirely when
/// the upstream bloc has zero child markets (returns `SizedBox.shrink()`)
/// so a no-data network blip cannot leave an empty strip on the home tab.
///
/// Mounted as `SliverToBoxAdapter(child: HomeMarketsNearYouSection())` by
/// the home tab content section; reads existing DI — no new bloc registered.
class HomeMarketsNearYouSection extends StatelessWidget {
  const HomeMarketsNearYouSection({super.key});

  static const double _cardWidth = 180;
  static const double _cardAspect = 4 / 5;
  static const int _skeletonCount = 4;

  static double _listHeight() => _cardWidth / _cardAspect + 8.h;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeMarketCategoriesBloc, HomeMarketCategoriesState>(
      builder: (context, state) {
        if (state is HomeMarketCategoriesLoaded) {
          final children = state.categoryData
              .where((m) => m.parentId != null)
              .toList(growable: false);
          if (children.isEmpty) {
            // No child markets → hide entire section.
            return const SizedBox.shrink();
          }
          return _LoadedSection(markets: children);
        }

        if (state is HomeMarketCategoriesLoading ||
            state is HomeMarketCategoriesInitial) {
          return const _LoadingSection(skeletonCount: _skeletonCount);
        }

        // Failure / unknown state → silently hide so a network blip on this
        // section doesn't break the rest of the home tab.
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadedSection extends StatelessWidget {
  final List<MarketCategoryData> markets;

  const _LoadedSection({required this.markets});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(),
        SizedBox(
          height: HomeMarketsNearYouSection._listHeight(),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            itemCount: markets.length,
            itemBuilder: (context, index) {
              final market = markets[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == markets.length - 1 ? 0 : 10.w,
                ),
                child: _MarketsNearYouCard(market: market),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

/// Card for a single child market. Owns its own lightweight fetch for the
/// per-market store list so the UI can render the open/closed pill and the
/// nearest distance without bloating the shared categories bloc with extra
/// per-item state.
class _MarketsNearYouCard extends StatefulWidget {
  final MarketCategoryData market;

  const _MarketsNearYouCard({required this.market});

  @override
  State<_MarketsNearYouCard> createState() => _MarketsNearYouCardState();
}

class _MarketsNearYouCardState extends State<_MarketsNearYouCard> {
  final MarketCategoryRepository _repo = MarketCategoryRepository();

  bool? _isOpen;
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    final slug = widget.market.slug;
    if (slug == null || slug.isEmpty) return;

    final response = await _repo.fetchStoresByMarketCategorySlug(
      marketCategorySlug: slug,
      page: 1,
      perPage: 50,
    );
    if (!mounted || response == null) return;

    try {
      final model = NearbyStoresModel.fromJson(response);
      final stores = model.data?.stores ?? const <StoreData>[];

      // isOpen = at least one store currently reports open.
      final bool isOpen =
          stores.any((s) => s.status?.isOpen == true);

      // distanceKm = min over non-null store.distance values.
      final distances = stores
          .map((s) => s.distance)
          .whereType<double>()
          .toList(growable: false);
      final double? nearest =
          distances.isEmpty ? null : distances.reduce(math.min);

      setState(() {
        _isOpen = isOpen;
        _distanceKm = nearest;
      });
    } catch (_) {
      // Parsing failure → keep nulls; card still renders with neutral state.
    }
  }

  void _openDetail() {
    final slug = widget.market.slug;
    if (slug == null || slug.isEmpty) return;
    GoRouter.of(context).push(
      AppRoutes.marketCategoryDetailPage,
      extra: {'slug': slug},
    );
  }

  @override
  Widget build(BuildContext context) {
    final market = widget.market;
    final imageUrl = market.image;

    return SizedBox(
      width: HomeMarketsNearYouSection._cardWidth,
      child: AspectRatio(
        aspectRatio: HomeMarketsNearYouSection._cardAspect,
        child: Material(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _openDetail,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ---------------- Full-bleed background ----------------
                if (imageUrl != null && imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    cacheManager: customCacheManager,
                    placeholder: (_, __) =>
                        Container(color: Colors.black26),
                    errorWidget: (_, __, ___) =>
                        Container(color: Colors.black26),
                  )
                else
                  Container(color: Colors.black26),

                // ---------------- Dark gradient overlay ----------------
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                      stops: [0.45, 1.0],
                    ),
                  ),
                  child: SizedBox.expand(),
                ),

                // ---------------- Open / Closed pill (top-end) ----------------
                PositionedDirectional(
                  top: 10,
                  end: 10,
                  child: _StatusPill(
                    isOpen: _isOpen,
                    openLabel: 'Open',
                    closedLabel: 'Closed',
                  ),
                ),

                // ---------------- Name + distance (bottom-start) ----------------
                PositionedDirectional(
                  bottom: 10,
                  start: 10,
                  end: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        market.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                      if (_distanceKm != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.70),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '${_distanceKm!.toStringAsFixed(1)} km',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.70),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Open/Closed status pill used in the top-end of each card. Renders a grey
/// neutral state while the per-card stores fetch is in flight so we never
/// flash a misleading "Closed" before data lands.
class _StatusPill extends StatelessWidget {
  final bool? isOpen;
  final String openLabel;
  final String closedLabel;

  const _StatusPill({
    required this.isOpen,
    required this.openLabel,
    required this.closedLabel,
  });

  @override
  Widget build(BuildContext context) {
    // While loading (isOpen == null) → neutral grey pill, blank text region.
    final bool resolved = isOpen != null;
    final bool open = isOpen == true;

    final Color bg = !resolved
        ? Colors.grey.shade600
        : (open ? const Color(0xFF2E7D32) : Colors.grey.shade700);
    final String label = !resolved ? '' : (open ? openLabel : closedLabel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.isEmpty ? ' ' : label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  final int skeletonCount;

  const _LoadingSection({required this.skeletonCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading shimmer (same shape as the real heading) so the layout
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
          height: HomeMarketsNearYouSection._listHeight(),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            itemCount: skeletonCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == skeletonCount - 1 ? 0 : 10.w,
                ),
                child: SizedBox(
                  width: HomeMarketsNearYouSection._cardWidth,
                  child: AspectRatio(
                    aspectRatio: HomeMarketsNearYouSection._cardAspect,
                    child: ShimmerWidget.rectangular(
                      isBorder: true,
                      height: double.infinity,
                      width: double.infinity,
                      borderRadius: 16,
                    ),
                  ),
                ),
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
                const Text(
                  'Markets Near You',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Discover markets close to your location',
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
            onTap: () =>
                GoRouter.of(context).push(AppRoutes.marketCategoryListPage),
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
