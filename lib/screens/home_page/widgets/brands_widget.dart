import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/home_page/bloc/brands/brands_bloc.dart';
import 'package:aasyou/utils/widgets/custom_brands_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/widgets/custom_shimmer.dart';
import '../../product_listing_page/model/product_listing_type.dart';

/// Brands section — Phase C3 restyle.
///
/// Behaviour:
///  - Horizontal swipeable carousel (carousel_slider) of brand "pages"
///  - Each page shows a fixed grid of restyled [CustomBrandsCard]s:
///      • mobile (<600dp)     : 4 brands per page
///      • small tablet (<900) : 5 brands per page
///      • desktop  (>=900)    : 7 brands per page
///  - Pagination dots are rendered below the carousel (one dot per page,
///    capped at 2 dots minimum visual when there are >1 pages).
///  - Section header row: title + "See All" link.
class BrandsSection extends StatefulWidget {
  final String brandsSectionTitle;
  final String categorySlug;

  const BrandsSection({
    super.key,
    required this.brandsSectionTitle,
    required this.categorySlug,
  });

  @override
  State<BrandsSection> createState() => _BrandsSectionState();
}

class _BrandsSectionState extends State<BrandsSection> {
  int _currentPage = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _brandsPerPage(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    if (w >= 900) return 7; // desktop / large tablet
    if (w >= 600) return 5; // small tablet
    return 4;               // phone
  }

  List<List<T>> _chunk<T>(List<T> items, int size) {
    final List<List<T>> pages = [];
    for (int i = 0; i < items.length; i += size) {
      pages.add(items.sublist(i, (i + size > items.length) ? items.length : i + size));
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandsBloc, BrandsState>(
      builder: (context, state) {
        if (state is BrandsLoaded) {
          if (state.brandsData.isEmpty) {
            return const SizedBox.shrink();
          }

          final int perPage = _brandsPerPage(context);
          final pages = _chunk(state.brandsData, perPage);

          // Card size mirrors CustomBrandsCard (64 phone / 80 tablet).
          final double cardSize = isTablet(context) ? 80 : 64;
          // Height = card + a little vertical breathing room.
          final double carouselHeight = cardSize + 16;

          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------- Header row --------
                Padding(
                  padding: EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0.h,
                    top: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.brandsSectionTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8.r),
                        onTap: () {
                          GoRouter.of(context).push(
                            AppRoutes.brandsListPage,
                            extra: {
                              'category-slug': widget.categorySlug,
                            },
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.seeAll ?? 'See All',
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
                ),

                // -------- Carousel --------
                CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: pages.length,
                  itemBuilder: (context, pageIndex, _) {
                    final pageItems = pages[pageIndex];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: pageItems.map((brand) {
                          return CustomBrandsCard(
                            brandName: brand.title ?? 'Brand',
                            brandImage: brand.logo ?? '',
                            onTap: () {
                              GoRouter.of(context).push(
                                AppRoutes.productListing,
                                extra: {
                                  'isTheirMoreCategory': false,
                                  'title': brand.title,
                                  'logo': brand.logo,
                                  'totalProduct': 10,
                                  'type': ProductListingType.brand,
                                  'identifier': brand.slug,
                                },
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: carouselHeight,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: false,
                    onPageChanged: (index, _) {
                      setState(() => _currentPage = index);
                    },
                  ),
                ),

                // -------- Pagination dots --------
                if (pages.length > 1) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (i) {
                      final bool active = i == _currentPage;
                      return GestureDetector(
                        onTap: () => _carouselController.animateToPage(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          width: active ? 16.w : 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: active
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 4.h),
                ],
              ],
            ),
          );
        } else if (state is BrandsLoading) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 12.0,
                  ),
                  child: ShimmerWidget.rectangular(
                    isBorder: true,
                    height: 18,
                    width: 200,
                    borderRadius: 15,
                  ),
                ),
                SizedBox(
                  height: 80.h,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        _brandsPerPage(context),
                        (_) => ShimmerWidget.rectangular(
                          isBorder: true,
                          height: isTablet(context) ? 80 : 64,
                          width: isTablet(context) ? 80 : 64,
                          borderRadius: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
