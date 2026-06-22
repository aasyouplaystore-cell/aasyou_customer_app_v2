import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/banner/banner_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/banner/banner_state.dart';
import 'package:aasyou/screens/home_page/bloc/brands/brands_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_state.dart';
import 'package:aasyou/screens/home_page/bloc/sub_category/sub_category_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/sub_category/sub_category_state.dart';
import 'package:aasyou/screens/home_page/model/featured_section_product_model.dart';
import 'package:aasyou/screens/home_page/widgets/banner_slider.dart';
import 'package:aasyou/screens/home_page/widgets/brands_widget.dart';
import 'package:aasyou/screens/home_page/widgets/sub_category_feature_section_widget.dart';
import 'package:aasyou/screens/settings/web_settings/model/web_settings_model.dart';
import 'package:aasyou/utils/widgets/custom_shimmer.dart';
import 'package:aasyou/utils/widgets/empty_states_page.dart';
import 'package:aasyou/utils/widgets/web_settings_gate.dart';

import 'home_featured_products_section.dart';
import 'home_mango_mania_section.dart';
import 'home_market_categories_section.dart';
import 'home_markets_near_you_section.dart';
import 'home_middle_banner_section.dart';
import 'home_popular_shops_section.dart';
import 'home_top_rated_section.dart';

class HomeTabContentSection extends StatelessWidget {
  final String brandsSectionTitle;
  final String categorySlug;
  final Widget loadingPlaceholder;
  final Widget Function(FeaturedSectionData section) buildFeatureSection;
  final VoidCallback onRetry;

  const HomeTabContentSection({
    super.key,
    required this.brandsSectionTitle,
    required this.categorySlug,
    required this.loadingPlaceholder,
    required this.buildFeatureSection,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerBloc, BannerState>(
      builder: (context, bannerState) {
        return BlocBuilder<SubCategoryBloc, SubCategoryState>(
          builder: (context, subCategoryState) {
            return BlocBuilder<FeatureSectionProductBloc,
                FeatureSectionProductState>(
              builder: (context, featureSectionState) {
                return BlocBuilder<BrandsBloc, BrandsState>(
                  builder: (context, brandsState) {
                    // /featured-sections is the only home endpoint that returns
                    // an explicit "Delivery not available at location" failure
                    // when the user's coords are outside any delivery zone.
                    // The other endpoints (categories, brands, banners) are
                    // global and return success even outside zones, so they
                    // cannot be trusted as zone indicators.
                    final zoneUnavailable =
                        featureSectionState is FeatureSectionProductFailed;
                    if (zoneUnavailable) {
                      return NoDeliveryLocationPage(onRetry: onRetry);
                    }
                    // success=true but the chosen category has no shops in
                    // the user's zone → show a category-specific empty
                    // state, NOT the global "we're not here yet" zone screen.
                    final categoryHasNoStores = featureSectionState
                            is FeatureSectionProductLoaded &&
                        featureSectionState.featureSectionProductData.isEmpty;
                    if (categoryHasNoStores) {
                      return NoStorePage(onRetry: onRetry);
                    }
                    // Visual rhythm: ~20px of breathing room between each
                    // major home section (designer mockup). Defined once
                    // here so the spacing stays consistent if sections are
                    // added/removed.
                    const SliverToBoxAdapter sectionGap = SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    );
                    return CustomScrollView(
                      clipBehavior: Clip.antiAlias,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // White breathing room between the orange-gradient
                        // header and the first banner — matches the designer
                        // mockup where the orange fades smoothly into white
                        // before content begins.
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 18),
                        ),
                        // 1. Top Banner (AutoPlayCarouselSlider, restyled in
                        //    Phase C/C4).
                        SliverToBoxAdapter(
                          child: _buildTopBanner(bannerState),
                        ),
                        sectionGap,
                        // 2. Market Categories (restyled card from B2).
                        const SliverToBoxAdapter(
                          child: HomeMarketCategoriesSection(),
                        ),
                        sectionGap,
                        // 3. Markets Near You (D1) - replaces the legacy
                        //    HomeBrowseStoresSection's "markets" role; renders
                        //    market-themed cards with open/closed + distance.
                        const SliverToBoxAdapter(
                          child: HomeMarketsNearYouSection(),
                        ),
                        sectionGap,
                        // 4. Popular Shops - replaces the legacy
                        //    HomeBrowseStoresSection. Uses the new
                        //    PopularShopCard (lib/utils/widgets/
                        //    popular_shop_card.dart) inside a horizontal
                        //    ListView with a "See All" link.
                        const SliverToBoxAdapter(
                          child: HomePopularShopsSection(),
                        ),
                        sectionGap,
                        // 5. Middle Banner (same AutoPlayCarouselSlider as #1).
                        const SliverToBoxAdapter(
                          child: HomeMiddleBannerSection(),
                        ),
                        sectionGap,
                        // 6. Featured Brands - gated by
                        //    `homeFeaturedBrandsSection`.
                        SliverToBoxAdapter(
                          child: WebSettingsGate(
                            flagKey: WebSettings.kHomeFeaturedBrandsSection,
                            child: BrandsSection(
                              brandsSectionTitle: brandsSectionTitle,
                              categorySlug: categorySlug,
                            ),
                          ),
                        ),
                        sectionGap,
                        // 7. Shop By Category - gated by
                        //    `homeShopByCategorySection`.
                        const SliverToBoxAdapter(
                          child: WebSettingsGate(
                            flagKey: WebSettings.kHomeShopByCategorySection,
                            child: SubCategoryFeatureSectionWidget(),
                          ),
                        ),
                        sectionGap,
                        // 8. Mango Mania (D2) - gated by `homeFeaturedSection`.
                        const SliverToBoxAdapter(
                          child: WebSettingsGate(
                            flagKey: WebSettings.kHomeFeaturedSection,
                            child: HomeMangoManiaSection(),
                          ),
                        ),
                        sectionGap,
                        // 9. Featured Products (C2) - gated by
                        //    `homeFeaturedProductsSection`.
                        const SliverToBoxAdapter(
                          child: WebSettingsGate(
                            flagKey: WebSettings.kHomeFeaturedProductsSection,
                            child: HomeFeaturedProductsSection(),
                          ),
                        ),
                        sectionGap,
                        // 10. Top Rated (C2) - gated by
                        //     `homeTopRatedSection`.
                        const SliverToBoxAdapter(
                          child: WebSettingsGate(
                            flagKey: WebSettings.kHomeTopRatedSection,
                            child: HomeTopRatedSection(),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 70),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTopBanner(BannerState state) {
    if (state is BannerLoaded) {
      return AutoPlayCarouselSlider(banners: state.topBannerData);
    }

    if (state is BannerLoading) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ShimmerWidget.rectangular(
          isBorder: true,
          height: 220,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
