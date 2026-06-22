import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_state.dart';
import 'package:aasyou/screens/product_listing_page/model/product_listing_type.dart';

import 'featured_section_filter.dart';
import 'home_featured_products_section.dart';

/// Phase C+D section widget that surfaces every `section_type == "top_rated"`
/// entry from the existing `FeatureSectionProductBloc`.
///
/// Mirrors [HomeFeaturedProductsSection] but pins the filter to the
/// "top_rated" bucket. The grid body and per-product tile are shared
/// (`FeaturedProductsGridBody`, `HomeFeaturedProductTile`) so the two
/// sections stay visually identical and behave identically for cart /
/// variant / ad-tracking interactions.
///
/// Visibility rules:
///   - Hidden until the bloc reaches the loaded state.
///   - Hidden when there are no top-rated products to show.
///
/// Will be wrapped by a `WebSettingsGate(flagKey: WebSettings.kHomeTopRatedSection)`
/// in the D-phase task; this widget itself does not consult `WebSettingsBloc`
/// so it can be reused/tested in isolation.
class HomeTopRatedSection extends StatelessWidget {
  const HomeTopRatedSection({super.key});

  /// `section_type` value emitted by the API for the "top rated" bucket.
  static const String _sectionType = 'top_rated';

  /// Hard cap on rendered products - matches the web Top Rated strip.
  static const int _maxProducts = 8;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureSectionProductBloc, FeatureSectionProductState>(
      builder: (context, state) {
        if (state is! FeatureSectionProductLoaded) {
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRatedHeader(
              title: filter.title,
              slug: filter.slug,
              totalCount: filter.totalCount,
            ),
            SizedBox(height: 6.h),
            FeaturedProductsGridBody(products: filter.products),
            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }
}

class _TopRatedHeader extends StatelessWidget {
  final String title;
  final String slug;
  final int? totalCount;

  const _TopRatedHeader({
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
