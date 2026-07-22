import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../config/helper.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/app_routes.dart';
import '../../../utils/widgets/custom_circular_progress_indicator.dart';
import '../../../utils/widgets/custom_image_container.dart';
import '../../../utils/widgets/custom_market_category_card.dart';
import '../../../utils/widgets/custom_refresh_indicator.dart';
import '../../../utils/widgets/custom_scaffold/custom_scaffold.dart';
import '../../../utils/widgets/empty_states_page.dart';
import '../../home_page/model/market_category_model.dart';
import '../../near_by_stores/view/nearyby_stores_page.dart';
import '../bloc/market_category_detail_bloc/market_category_detail_bloc.dart';
import '../bloc/market_category_detail_bloc/market_category_detail_event.dart';
import '../bloc/market_category_detail_bloc/market_category_detail_state.dart';
import '../bloc/market_category_stores_bloc/market_category_stores_bloc.dart';
import '../bloc/market_category_stores_bloc/market_category_stores_event.dart';
import '../bloc/market_category_stores_bloc/market_category_stores_state.dart';

/// Detail screen for a single Market Category.
///
/// Mirrors the web `/market-categories/[slug]` page:
///   * Banner hero with title + description (or leading thumb fallback
///     when `banner` is empty).
///   * Subcategories grid (recursive drill-down via Market Category card).
///   * Stores list filtered by `market_category_slug`.
class MarketCategoryDetailPage extends StatelessWidget {
  final String slug;

  const MarketCategoryDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MarketCategoryDetailBloc()
            ..add(FetchMarketCategoryDetail(slug: slug)),
        ),
        BlocProvider(
          create: (_) => MarketCategoryStoresBloc()
            ..add(FetchMarketCategoryStores(marketCategorySlug: slug)),
        ),
      ],
      child: _MarketCategoryDetailView(slug: slug),
    );
  }
}

class _MarketCategoryDetailView extends StatefulWidget {
  final String slug;
  const _MarketCategoryDetailView({required this.slug});

  @override
  State<_MarketCategoryDetailView> createState() =>
      _MarketCategoryDetailViewState();
}

class _MarketCategoryDetailViewState extends State<_MarketCategoryDetailView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    if (current >= (maxScroll - 200)) {
      final storesBloc = context.read<MarketCategoryStoresBloc>();
      if (storesBloc.state is MarketCategoryStoresLoaded) {
        final loaded = storesBloc.state as MarketCategoryStoresLoaded;
        if (!loaded.hasReachedMax && !storesBloc.isLoadingMore) {
          storesBloc.add(LoadMoreMarketCategoryStores(
            marketCategorySlug: widget.slug,
          ));
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    context.read<MarketCategoryDetailBloc>().add(
          FetchMarketCategoryDetail(slug: widget.slug),
        );
    context.read<MarketCategoryStoresBloc>().add(
          FetchMarketCategoryStores(marketCategorySlug: widget.slug),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.slug.isEmpty) {
      // Defensive guard for direct deep-links without a slug.
      return CustomScaffold(
        showViewCart: true,
        showAppBar: true,
        title: l10n?.marketCategories ?? 'Market Categories',
        body: Center(
            child: NoCategoryPage(
                onRetry: () => Navigator.maybeOf(context)?.maybePop())),
      );
    }

    return BlocBuilder<MarketCategoryDetailBloc, MarketCategoryDetailState>(
      builder: (context, detailState) {
        String title = l10n?.marketCategories ?? 'Market Categories';
        if (detailState is MarketCategoryDetailLoaded) {
          title = detailState.mainCategory?.title ??
              (l10n?.marketCategories ?? 'Market Categories');
        }

        return CustomScaffold(
          showViewCart: true,
          showAppBar: true,
          title: title,
          onConnectivityRestored: (_) async {
            _onRefresh();
          },
          appBarActions: [
            IconButton(
              onPressed: () {
                GoRouter.of(context).push(AppRoutes.search);
              },
              icon: const Icon(TablerIcons.search),
            ),
          ],
          body: _buildBody(context, detailState),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, MarketCategoryDetailState detailState) {
    if (detailState is MarketCategoryDetailLoading ||
        detailState is MarketCategoryDetailInitial) {
      return const Center(child: CustomCircularProgressIndicator());
    }
    if (detailState is MarketCategoryDetailFailed) {
      return Center(child: NoCategoryPage(onRetry: _onRefresh));
    }
    if (detailState is MarketCategoryDetailLoaded) {
      return CustomRefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HeroHeader(mainCategory: detailState.mainCategory),
            ),
            SliverToBoxAdapter(
              child: _TitleDescription(mainCategory: detailState.mainCategory),
            ),
            if (detailState.subcategories.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: AppLocalizations.of(context)?.shopByMarketCategory ??
                      'Shop by market',
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                sliver: _SubcategoriesSliverGrid(
                  subcategories: detailState.subcategories,
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: AppLocalizations.of(context)?.storesInThisMarket ??
                    'Stores in this market',
              ),
            ),
            _StoresSliverSection(marketCategorySlug: widget.slug),
            const SliverToBoxAdapter(child: SizedBox(height: 70)),
          ],
        ),
      );
    }

    return const Center(child: CustomCircularProgressIndicator());
  }
}

/// Banner hero with CachedNetworkImage and gradient overlay.
///
/// Falls back to a small leading thumbnail using [_HeroLeadingThumb] when
/// the backend doesn't provide a banner image (so the screen never has a
/// blank hero).
class _HeroHeader extends StatelessWidget {
  final MarketCategoryData? mainCategory;
  const _HeroHeader({required this.mainCategory});

  static bool _isCustomColor(String? hex) {
    if (hex == null) return false;
    final v = hex.trim().toLowerCase();
    if (v.isEmpty) return false;
    return v != '#000000' && v != '#ffffff' && v != '#000' && v != '#fff';
  }

  @override
  Widget build(BuildContext context) {
    final cat = mainCategory;
    final banner = cat?.banner;
    final image = cat?.image;

    if (banner != null && banner.isNotEmpty) {
      return AspectRatio(
        aspectRatio: 3 / 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop so contain-letterbox gaps read as a deliberate surface
            // (the legibility gradient below tints the whole hero).
            Container(color: AppTheme.primaryColor.withValues(alpha: 0.08)),
            CachedNetworkImage(
              imageUrl: banner,
              fit: BoxFit.contain,
              memCacheWidth: 1200,
              placeholder: (_, __) => Container(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppTheme.primaryColor.withValues(alpha: 0.10),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.white70,
                  size: 36,
                ),
              ),
            ),
            // Gradient overlay for legibility of any badge / future text.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            // Store count pill intentionally hidden — design preference.
          ],
        ),
      );
    }

    // No banner — use a smaller leading thumb hero w/ brand soft bg or
    // the backend background_color, keeping visual continuity.
    final bgColor = _isCustomColor(cat?.backgroundColor)
        ? hexStringToColor(cat!.backgroundColor)
        : null;

    return Container(
      height: 110.h,
      color: bgColor ?? AppTheme.primaryColor.withValues(alpha: 0.10),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          if (image != null && image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80.w,
                height: 80.w,
                child: CustomImageContainer(
                  imagePath: image,
                  fit: BoxFit.contain,
                  memCacheWidth: 240,
                ),
              ),
            ),
          if (image != null && image.isNotEmpty) SizedBox(width: 12.w),
          Expanded(
            child: Text(
              cat?.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // Store count pill intentionally hidden — design preference.
        ],
      ),
    );
  }
}


/// Title + description block under the hero.
class _TitleDescription extends StatelessWidget {
  final MarketCategoryData? mainCategory;
  const _TitleDescription({required this.mainCategory});

  @override
  Widget build(BuildContext context) {
    // Title is already shown in the app bar — render only the description here.
    final description = mainCategory?.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 13.sp,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.75),
          height: 1.4,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Sliver grid wrapper around [CustomMarketCategoryCard] so the detail
/// page's nested grid scrolls with the rest of the screen and supports
/// recursive drill-down (tap pushes another detail screen via the same
/// route).
class _SubcategoriesSliverGrid extends StatelessWidget {
  final List<MarketCategoryData> subcategories;
  const _SubcategoriesSliverGrid({required this.subcategories});

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 8;
    if (w >= 800) return 5;
    if (w >= 600) return 4;
    if (w >= 400) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = MediaQuery.of(context).size.width * 0.03;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount(context),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 4 / 5,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = subcategories[index];
          return CustomMarketCategoryCard(
            data: item,
            onTap: () {
              final slug = item.slug ?? '';
              if (slug.isEmpty) return;
              GoRouter.of(context).push(
                AppRoutes.marketCategoryDetailPage,
                extra: {'slug': slug},
              );
            },
          );
        },
        childCount: subcategories.length,
      ),
    );
  }
}

/// Stores sliver section. Reuses [StoreCardBanner] from the Nearby Stores
/// page so the visual identity matches that screen exactly.
class _StoresSliverSection extends StatelessWidget {
  final String marketCategorySlug;
  const _StoresSliverSection({required this.marketCategorySlug});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketCategoryStoresBloc, MarketCategoryStoresState>(
      builder: (context, state) {
        if (state is MarketCategoryStoresLoading ||
            state is MarketCategoryStoresInitial) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CustomCircularProgressIndicator()),
            ),
          );
        }

        if (state is MarketCategoryStoresFailed) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: NoStorePage(
                  onRetry: () {
                    context.read<MarketCategoryStoresBloc>().add(
                          FetchMarketCategoryStores(
                            marketCategorySlug: marketCategorySlug,
                          ),
                        );
                  },
                ),
              ),
            ),
          );
        }

        if (state is MarketCategoryStoresLoaded) {
          final stores = state.stores.stores;
          if (stores.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: NoStorePage(
                    onRetry: () {
                      context.read<MarketCategoryStoresBloc>().add(
                            FetchMarketCategoryStores(
                              marketCategorySlug: marketCategorySlug,
                            ),
                          );
                    },
                  ),
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= stores.length) {
                  return state.hasReachedMax
                      ? const SizedBox.shrink()
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child:
                              Center(child: CustomCircularProgressIndicator()),
                        );
                }
                final store = stores[index];
                return StoreCardBanner(
                  key: Key(store.slug ?? store.id.toString()),
                  store: store,
                  isRecommended: store.isRecommended ?? false,
                  onTap: () {
                    GoRouter.of(context).push(
                      AppRoutes.nearbyStoreDetails,
                      extra: {
                        'store-slug': store.slug,
                        'store-name': store.name,
                      },
                    );
                  },
                );
              },
              childCount: stores.length + (state.hasReachedMax ? 0 : 1),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
