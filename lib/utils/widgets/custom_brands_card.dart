import 'package:flutter/material.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';

/// Flat, edge-to-edge brand card.
///
/// Phase B (B4) restyle:
///  - No outer padding
///  - 12dp rounded ClipRRect on the outer surface
///  - Logo fills the entire card with BoxFit.cover
///  - Fixed size: 64x64 phone / 80x80 tablet
///  - InkWell tap ripple (caller wires routing via [onTap])
///  - Brand name text intentionally removed — logo speaks for itself.
class CustomBrandsCard extends StatelessWidget {
  final String brandName;
  final String brandImage;
  final VoidCallback? onTap;

  const CustomBrandsCard({
    super.key,
    required this.brandName,
    required this.brandImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isTablet(context) ? 80 : 64;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            child: CustomImageContainer(
              imagePath: brandImage,
              width: size,
              height: size,
              // Brand LOGO — never edge-crop a logo.
              fit: BoxFit.contain,
              memCacheWidth: 200,
            ),
          ),
        ),
      ),
    );
  }
}
