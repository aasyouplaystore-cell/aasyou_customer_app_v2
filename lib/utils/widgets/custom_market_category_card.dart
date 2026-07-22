import 'package:flutter/material.dart';

import '../../screens/home_page/model/market_category_model.dart';

/// Phase B card primitive for market categories.
///
/// Full-bleed product image with a bottom gradient scrim and a stacked
/// title + subtitle (searchLabels join) at the bottom-start. Aspect-locked
/// to 4:5 and clipped with a 16dp radius.
///
/// RTL-aware via [PositionedDirectional]. Backend customisation fields
/// (background_color / font_color / background_image) are intentionally not
/// honored in this variant — the design is a uniform image+scrim treatment.
class CustomMarketCategoryCard extends StatelessWidget {
  final MarketCategoryData data;
  final VoidCallback? onTap;

  const CustomMarketCategoryCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String title = data.title ?? '';
    final String? image = data.image;
    final String subtitle =
        (data.searchLabels?.take(3).join(' • ') ?? '');

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: full-bleed background image
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    image: (image != null && image.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(image),
                            // Full-bleed image+scrim tile: title overlays the photo,
                            // so cover is the intended design here.
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),

                // Layer 2: bottom gradient scrim for legibility
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),

                // Layer 3: bottom-start title + subtitle
                PositionedDirectional(
                  bottom: 12,
                  start: 12,
                  end: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.2,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
