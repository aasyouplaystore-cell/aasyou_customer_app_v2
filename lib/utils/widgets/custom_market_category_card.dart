import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/helper.dart';
import '../../screens/home_page/model/market_category_model.dart';
import 'custom_image_container.dart';

/// Card widget mirroring the web [MarketCategoryCard] design:
/// - Title at top-start (RTL aware via Positioned.start)
/// - Optional store count pill (brand primary background, white text)
/// - Product image fills the bottom 70%
/// - Honors backend customisation: background_type, background_color,
///   background_image, font_color
/// - Falls back to onSecondary card colour when no custom bg is set so that
///   light/dark themes still work, mirroring [CustomSubCategoryCard].
///
/// Pure-black / pure-white backend defaults are skipped via [_isCustomColor]
/// to preserve readable contrast (mirrors the web `isCustomColor` helper).
class CustomMarketCategoryCard extends StatelessWidget {
  final MarketCategoryData data;
  final VoidCallback? onTap;

  const CustomMarketCategoryCard({
    super.key,
    required this.data,
    this.onTap,
  });

  /// Web parity: ignore '#000000' / '#ffffff' / '#000' / '#fff' / '' defaults.
  static bool _isCustomColor(String? hex) {
    if (hex == null) return false;
    final norm = hex.trim().toLowerCase();
    if (norm.isEmpty) return false;
    return norm != '#000000' &&
        norm != '#ffffff' &&
        norm != '#000' &&
        norm != '#fff';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Resolve custom background colour / font colour (skipping pure b/w defaults)
    final Color? bgColor = _isCustomColor(data.backgroundColor)
        ? hexStringToColor(data.backgroundColor)
        : null;
    final Color? fontColor = _isCustomColor(data.fontColor)
        ? hexStringToColor(data.fontColor)
        : null;

    final bool hasBgImage = data.backgroundType == 'image' &&
        (data.backgroundImage?.isNotEmpty ?? false);

    final String title = data.title ?? '';
    final String? image = data.image;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final borderRadius = BorderRadius.circular(
          cardWidth >= 120 ? 18 : 14,
        );

        // Background decoration logic mirroring web tileStyle:
        // 1) image > 2) custom color > 3) theme onSecondary (default card bg)
        final BoxDecoration decoration = BoxDecoration(
          borderRadius: borderRadius,
          color: hasBgImage ? null : (bgColor ?? theme.colorScheme.onSecondary),
          image: hasBgImage
              ? DecorationImage(
                  image: NetworkImage(data.backgroundImage!),
                  fit: BoxFit.cover,
                )
              : null,
        );

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Container(
                decoration: decoration,
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Image fills the bottom 70% (web parity: max 95% inset)
                    if (image != null && image.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        height: constraints.maxHeight * 0.70 +
                            // AspectRatio drives height; fall back to a
                            // ratio-based calc when maxHeight is unbounded.
                            0,
                        child: FractionallySizedBox(
                          alignment: AlignmentDirectional.bottomEnd,
                          widthFactor: 0.95,
                          heightFactor: 0.95,
                          child: CustomImageContainer(
                            imagePath: image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                    // Title + optional store-count pill at top-start.
                    // PositionedDirectional honours RTL automatically.
                    PositionedDirectional(
                      top: 10.h,
                      start: 10.w,
                      end: 8.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: cardWidth >= 120 ? 14 : 13,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: fontColor ?? theme.colorScheme.onSurface,
                            ),
                          ),
                          // Store count badge intentionally hidden — design preference.
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

