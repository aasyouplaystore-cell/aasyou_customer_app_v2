import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/widgets/custom_shimmer.dart';
import '../../bloc/banner/banner_bloc.dart';
import '../../bloc/banner/banner_state.dart';
import '../banner_slider.dart';

/// Home tab section that renders the middle/carousel banner as a standalone
/// slice of UI, decoupled from [HomeFeaturedSection].
///
/// Previously the middle banner was passed in as a `Widget middleBanner`
/// constructor param to `HomeFeaturedSection` and injected between the first
/// featured section and the rest. The new home tab ordering requires the
/// carousel to live between "Browse Stores" and "Featured Brands", so it has
/// been promoted to its own section widget that reads the same [BannerBloc]
/// state directly.
///
/// Behavior (web parity):
///   - [BannerLoaded] -> [AutoPlayCarouselSlider] fed with
///     `state.middleBannerData`. The slider itself returns
///     `SizedBox.shrink()` when its `banners` list is empty, so empty
///     middle-banner data auto-hides without bubbling up.
///   - [BannerLoading] -> 220-tall rectangular shimmer with the same 20px
///     padding used by the top banner / legacy `middleBannersWidget()`.
///   - Any other state (initial / failed) -> `SizedBox.shrink()`. Banner
///     failures are silent here so they cannot interfere with the
///     `FeatureSectionProductFailed -> NoDeliveryLocationPage` cascade
///     owned by `home_tab_content_section.dart`.
///
/// Mounted as a `SliverToBoxAdapter(child: HomeMiddleBannerSection())`
/// inside `home_tab_content_section.dart`.
class HomeMiddleBannerSection extends StatelessWidget {
  const HomeMiddleBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerBloc, BannerState>(
      builder: (context, state) {
        if (state is BannerLoaded) {
          // AutoPlayCarouselSlider already returns SizedBox.shrink() when the
          // banners list is empty, so an empty middleBannerData auto-hides.
          return AutoPlayCarouselSlider(banners: state.middleBannerData);
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
      },
    );
  }
}
