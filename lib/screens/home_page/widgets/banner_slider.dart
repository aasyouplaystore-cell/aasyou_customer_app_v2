import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/product_listing_page/model/product_listing_type.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';

import '../../../utils/widgets/custom_shimmer.dart';
import '../bloc/banner/banner_bloc.dart';
import '../bloc/banner/banner_state.dart';
import '../model/banner_model.dart';

/// Auto-playing carousel slider used for both the top hero banner and the
/// middle banner section on the home tab.
///
/// Responsive behavior (Phase C/D):
///   - Each slide is wrapped in an [AspectRatio] so the artwork keeps a
///     predictable aspect across form factors:
///       * phone   (<600w)         -> 16:10
///       * tablet  (600w - 1024w)  -> 3:1
///       * desktop (>=1024w)       -> 4:1
///   - [CarouselOptions.viewportFraction] is `1.0` on mobile/tablet (single
///     banner fills the viewport) and `0.5` on desktop (two banners visible).
///   - Pagination dots are clamped to `min(banners.length, 5)`, so collections
///     with >5 banners never render a runaway dot row.
///   - The previous full-bleed overlay decoration and the 25px outer chrome
///     have been removed. The image now fills the slide edge-to-edge.
///   - On tap, [BannerData.customUrl] (the cta link) wins when present:
///     internal URLs are routed via [GoRouter] (path-only segment), and
///     external URLs are opened with `url_launcher`. When no cta link is set,
///     the original type-based switch (`brand` / `category` / `product`) is
///     used as the fallback.
class AutoPlayCarouselSlider extends StatefulWidget {
  final List<BannerData> banners;
  final Duration autoPlayInterval;

  const AutoPlayCarouselSlider({
    super.key,
    required this.banners,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  State<AutoPlayCarouselSlider> createState() => _AutoPlayCarouselSliderState();
}

class _AutoPlayCarouselSliderState extends State<AutoPlayCarouselSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Responsive breakpoints (logical px, width-based to match web parity).
  static const double _tabletBreakpoint = 600;
  static const double _desktopBreakpoint = 1024;

  double _aspectRatioForWidth(double width) {
    if (width >= _desktopBreakpoint) return 4 / 1;
    if (width >= _tabletBreakpoint) return 3 / 1;
    return 2 / 1;
  }

  double _viewportFractionForWidth(double width) {
    // Desktop: show 2 banners side-by-side. Phone/tablet: single banner.
    return width >= _desktopBreakpoint ? 0.5 : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final double aspect = _aspectRatioForWidth(width);
        final double viewportFraction = _viewportFractionForWidth(width);
        // Per-slide width once viewportFraction is applied.
        final double slideWidth = width * viewportFraction;
        final double sliderHeight = slideWidth / aspect;

        // Max 5 pagination dots; if >5 banners only first 5 get dots.
        final int dotCount =
            widget.banners.length < 5 ? widget.banners.length : 5;

        return Column(
          children: [
            SizedBox(
              height: sliderHeight,
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: widget.banners.length,
                itemBuilder: (context, index, realIndex) {
                  final banner = widget.banners[index];
                  return GestureDetector(
                    onTap: () => _handleBannerTap(banner, context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: aspect,
                          child: CustomImageContainer(
                            imagePath: banner.bannerImage ?? '',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: sliderHeight,
                  viewportFraction: viewportFraction,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayInterval: widget.autoPlayInterval,
                  autoPlayAnimationDuration: const Duration(milliseconds: 600),
                  autoPlayCurve: Curves.easeInOut,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                dotCount,
                (index) {
                  final bool isActive = _currentIndex == index;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: isActive ? 5 : 4,
                    width: isActive ? 5 : 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tap handling
  // ---------------------------------------------------------------------------

  void _handleBannerTap(BannerData banner, BuildContext context) {
    final String? cta = banner.customUrl?.trim();
    if (cta != null && cta.isNotEmpty) {
      _openCtaLink(cta, context);
      return;
    }
    _navigateByType(banner, context);
  }

  void _openCtaLink(String cta, BuildContext context) {
    Uri? uri;
    try {
      uri = Uri.parse(cta);
    } catch (_) {
      uri = null;
    }

    // Internal: relative path or empty scheme/host -> GoRouter push.
    final bool isInternal = uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https');

    if (isInternal) {
      // Use only the path (+ query, if any) so GoRouter can resolve it.
      String internalPath;
      if (uri != null && uri.path.isNotEmpty) {
        internalPath = uri.path;
        if (uri.hasQuery) internalPath = '$internalPath?${uri.query}';
      } else {
        internalPath = cta.startsWith('/') ? cta : '/$cta';
      }
      try {
        GoRouter.of(context).push(internalPath);
      } catch (e) {
        log('Banner cta internal push failed for "$internalPath": $e');
      }
      return;
    }

    // External: hand off to url_launcher.
    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
      log('Banner cta external launch failed for "$cta": $e');
      return false;
    });
  }

  void _navigateByType(BannerData banner, BuildContext context) {
    switch (banner.type) {
      case 'brand':
        GoRouter.of(context).push(
          AppRoutes.productListing,
          extra: {
            'isTheirMoreCategory': false,
            'title': banner.title,
            'logo': banner.bannerImage,
            'totalProduct': '',
            'type': ProductListingType.brand,
            'identifier': banner.brandSlug,
          },
        );
        break;

      case 'category':
        GoRouter.of(context).push(
          AppRoutes.productListing,
          extra: {
            'isTheirMoreCategory': false,
            'title': banner.title,
            'logo': banner.bannerImage,
            'totalProduct': '',
            'type': ProductListingType.category,
            'identifier': banner.categorySlug,
          },
        );
        break;

      case 'product':
        final slug = banner.productSlug?.toString() ?? '';
        if (slug.isEmpty) return;
        GoRouter.of(context).push(
          AppRoutes.productDetailPage,
          extra: {'productSlug': slug},
        );
        break;

      default:
        log('Unknown banner type: ${banner.type}');
        return;
    }
  }
}

Widget middleBannersWidget() {
  return BlocBuilder<BannerBloc, BannerState>(
    builder: (BuildContext context, BannerState state) {
      if (state is BannerLoaded) {
        return AutoPlayCarouselSlider(banners: state.middleBannerData);
      } else if (state is BannerLoading) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ShimmerWidget.rectangular(isBorder: true, height: 220),
        );
      }
      return const SizedBox.shrink();
    },
  );
}
