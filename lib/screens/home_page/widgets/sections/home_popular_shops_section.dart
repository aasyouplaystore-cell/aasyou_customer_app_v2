import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/app_routes.dart';
import '../../../../utils/widgets/custom_shimmer.dart';
import '../../../../utils/widgets/popular_shop_card.dart';
import '../../../near_by_stores/bloc/near_by_store/near_by_store_bloc.dart';
import '../../../near_by_stores/model/near_by_store_model.dart';

/// Home tab section: "Popular Shops".
///
/// Replaces the legacy [HomeBrowseStoresSection] strip. Reuses the same
/// globally-registered [NearByStoreBloc] (see `global_bloc_providers.dart`)
/// so no new DI is added, but renders the items via the Phase B
/// [PopularShopCard] primitive instead of the bespoke inline card, matching
/// the web "Popular Shops" swiper.
///
/// Visibility rules (mirror the legacy section):
///   * Hidden entirely for single-vendor builds (no nearby-stores concept).
///   * Hidden entirely when the bloc reports zero stores (no empty strip).
///   * Silently hidden on failure so a network blip on this section cannot
///     break the rest of the home tab or interfere with the
///     `FeatureSectionProductFailed -> NoDeliveryLocationPage` cascade.
///   * Shows a shimmer skeleton row while loading.
class HomePopularShopsSection extends StatelessWidget {
  const HomePopularShopsSection({super.key});

  /// Number of columns in the popular-shops grid. Mobile = 2 (per designer
  /// mockup), tablet = 3, large tablet = 4.
  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    return 2;
  }

  /// Max grid rows to keep the section compact - the "See All" link routes
  /// to the full list page when there are more.
  int _maxVisible(BuildContext context) {
    final cols = _crossAxisCount(context);
    return cols * 2; // 2 rows
  }

  @override
  Widget build(BuildContext context) {
    if (AppHelpers.systemVendorTypeIsSingle) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<NearByStoreBloc, NearByStoreState>(
      builder: (context, state) {
        final crossAxisCount = _crossAxisCount(context);
        final maxVisible = _maxVisible(context);
        if (state is NearByStoreLoaded) {
          final stores = state.stores.stores;
          if (stores.isEmpty) {
            return const SizedBox.shrink();
          }
          return _LoadedSection(
            stores: stores,
            crossAxisCount: crossAxisCount,
            maxVisible: maxVisible,
          );
        }

        if (state is NearByStoreLoading || state is NearByStoreInitial) {
          return _LoadingSection(
            crossAxisCount: crossAxisCount,
            skeletonCount: maxVisible,
          );
        }

        // NearByStoreFailed (or anything else) -> silently hide.
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadedSection extends StatelessWidget {
  final List<StoreData> stores;
  final int crossAxisCount;
  final int maxVisible;

  const _LoadedSection({
    required this.stores,
    required this.crossAxisCount,
    required this.maxVisible,
  });

  @override
  Widget build(BuildContext context) {
    final visible =
        stores.length > maxVisible ? stores.sublist(0, maxVisible) : stores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visible.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              return PopularShopCard(store: visible[index]);
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _LoadingSection extends StatelessWidget {
  final int crossAxisCount;
  final int skeletonCount;

  const _LoadingSection({
    required this.crossAxisCount,
    required this.skeletonCount,
  });

  @override
  Widget build(BuildContext context) {
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
                width: 160,
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: skeletonCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              return ShimmerWidget.rectangular(
                isBorder: true,
                height: double.infinity,
                width: double.infinity,
                borderRadius: 12,
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
          const Expanded(
            child: Text(
              'Popular Shops',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
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
}
