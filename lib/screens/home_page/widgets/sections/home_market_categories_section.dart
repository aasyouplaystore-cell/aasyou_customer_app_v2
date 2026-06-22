import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../router/app_routes.dart';
import '../../../../utils/widgets/custom_market_category_card.dart';
import '../../../../utils/widgets/custom_shimmer.dart';
import '../../bloc/market_category/market_category_bloc.dart';
import '../../bloc/market_category/market_category_state.dart';
import '../../model/market_category_model.dart';

/// Home tab section showing a horizontal scrolling list of market categories.
/// Mirrors [SubCategoryFeatureSectionWidget]'s heading + see-all pattern,
/// but renders a horizontal `ListView.separated` instead of a vertical grid.
///
/// Mirrors the web `HomeMarketCategories` swiper:
///   - title "Market Categories" + description "Browse markets near you"
///   - "See all" link → /market-categories (listing screen)
///   - autoplay-style horizontal scroller of cards
///   - hides itself when there are zero items (no skeleton stuck on screen)
///   - shows shimmer skeleton while loading
///
/// Mounted as a `SliverToBoxAdapter(child: HomeMarketCategoriesSection())`
/// inside `home_tab_content_section.dart`, between the top banner and the
/// existing `SubCategoryFeatureSectionWidget`.
class HomeMarketCategoriesSection extends StatelessWidget {
  const HomeMarketCategoriesSection({super.key});

  static const int _maxItems = 20;
  static const int _skeletonCount = 8;

  /// Card width for the horizontal scroller — tuned so the card's 4/5 aspect
  /// produces a ~190 high tile on phones (enough room for two-line titles
  /// like "Building Materials") and scales gracefully on tablets.
  double _cardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 170;
    if (screenWidth >= 800) return 160;
    if (screenWidth >= 600) return 155;
    return 150;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeMarketCategoriesBloc, HomeMarketCategoriesState>(
      builder: (context, state) {
        if (state is HomeMarketCategoriesLoaded) {
          if (state.categoryData.isEmpty) {
            // Hide section completely when there are no market categories
            // (matches web `shouldHide` behaviour).
            return const SizedBox.shrink();
          }
          return _LoadedSection(
            categories: state.categoryData,
            cardWidth: _cardWidth(context),
            maxItems: _maxItems,
          );
        }

        if (state is HomeMarketCategoriesLoading ||
            state is HomeMarketCategoriesInitial) {
          return _LoadingSection(
            cardWidth: _cardWidth(context),
            skeletonCount: _skeletonCount,
          );
        }

        // HomeMarketCategoriesFailed (or anything else) → silently hide so a
        // network blip on this section doesn't break the rest of the home tab.
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadedSection extends StatelessWidget {
  final List<MarketCategoryData> categories;
  final double cardWidth;
  final int maxItems;

  const _LoadedSection({
    required this.categories,
    required this.cardWidth,
    required this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final visible = categories.length > maxItems
        ? categories.sublist(0, maxItems)
        : categories;

    // 4:5 aspect → height = width * 5/4. Add a tiny vertical padding buffer.
    final listHeight = cardWidth * (5 / 4) + 8.h;

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
                child: CustomMarketCategoryCard(
                  data: item,
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

  void _openDetail(BuildContext context, MarketCategoryData item) {
    final slug = item.slug;
    if (slug == null || slug.isEmpty) return;
    GoRouter.of(context).push(
      AppRoutes.marketCategoryDetailPage,
      extra: {'slug': slug},
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
    final listHeight = cardWidth * (5 / 4) + 8.h;

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
                child: const MarketCategoryCardSkeleton(),
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
                  l10n?.marketCategories ?? 'Market Categories',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n?.marketCategoriesDescription ??
                      'Browse markets near you',
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

/// Skeleton for a single market category card while data is loading.
/// Exported as a top-level widget so other surfaces (e.g. the listing screen's
/// grid) can reuse it.
class MarketCategoryCardSkeleton extends StatelessWidget {
  const MarketCategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final borderRadius = cardWidth >= 120 ? 18.0 : 14.0;

        return AspectRatio(
          aspectRatio: 4 / 5,
          child: ShimmerWidget.rectangular(
            isBorder: true,
            height: double.infinity,
            width: double.infinity,
            borderRadius: borderRadius,
          ),
        );
      },
    );
  }
}
