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
import 'package:aasyou/utils/widgets/custom_shimmer.dart';
import 'package:aasyou/utils/widgets/empty_states_page.dart';

import 'home_browse_stores_section.dart';
import 'home_featured_section.dart';
import 'home_market_categories_section.dart';
import 'home_middle_banner_section.dart';

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
                    return CustomScrollView(
                      clipBehavior: Clip.antiAlias,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // 1. Top Banner
                        SliverToBoxAdapter(
                          child: _buildTopBanner(bannerState),
                        ),
                        // 2. Market Categories
                        const SliverToBoxAdapter(
                          child: HomeMarketCategoriesSection(),
                        ),
                        // 3. Browse Stores
                        const SliverToBoxAdapter(
                          child: HomeBrowseStoresSection(),
                        ),
                        // 4. Carousel / Middle Banner
                        const SliverToBoxAdapter(
                          child: HomeMiddleBannerSection(),
                        ),
                        // 5. Featured Brands
                        SliverToBoxAdapter(
                          child: BrandsSection(
                            brandsSectionTitle: brandsSectionTitle,
                            categorySlug: categorySlug,
                          ),
                        ),
                        // 6. Shop By Category
                        const SliverToBoxAdapter(
                          child: SubCategoryFeatureSectionWidget(),
                        ),
                        // 7. Rest of Home Featured Section
                        SliverToBoxAdapter(
                          child: HomeFeaturedSection(
                            buildFeatureSection: buildFeatureSection,
                            loadingPlaceholder: loadingPlaceholder,
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
