import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/helper.dart';
import '../../../utils/widgets/price_utils.dart';

class PriceRowWidget extends StatelessWidget {
  final double originalPrice;
  final double? salePrice;
  final double? fontSize;
  final double? originalFontSize;
  final double? discountFontSize;
  final FontWeight? fontWeight;
  final Color? priceColor;
  final Color? originalPriceColor;
  final Color? discountBackgroundColor;
  final Color? discountTextColor;

  const PriceRowWidget({
    super.key,
    required this.originalPrice,
    this.salePrice,
    this.fontSize,
    this.originalFontSize,
    this.discountFontSize,
    this.fontWeight,
    this.priceColor,
    this.originalPriceColor,
    this.discountBackgroundColor,
    this.discountTextColor,
  });

  @override
  Widget build(BuildContext context) {
    // ────────────────────────────────────────────────
    final displayPrice = salePrice != null && salePrice! > 0 ? salePrice! : originalPrice;

    // Only show discount UI if there's a meaningful discount
    final hasRealDiscount = salePrice != null &&
        salePrice! > 0 &&
        salePrice! < originalPrice &&
        (originalPrice - salePrice!).abs() > 0.01; // avoid floating-point noise

    final discountPercentage = hasRealDiscount
        ? PriceUtils.calculateDiscountPercentage(originalPrice, salePrice!)
        : 0;

    // ────────────────────────────────────────────────
    return Row(
      mainAxisSize: MainAxisSize.min,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Main (effective) price ─ always shown
        Text(
          PriceUtils.formatPrice(displayPrice),
          style: TextStyle(
            fontSize: 18,
            fontWeight: fontWeight ?? FontWeight.bold,
            color: priceColor ?? Theme.of(context).colorScheme.tertiary,
            letterSpacing: 0.2,
          ),
        ),

        // Only show crossed price + badge when there is a real discount
        if (hasRealDiscount) ...[
          const SizedBox(width: 8),

          // Original (struck-through) price
          Text(
            PriceUtils.formatPrice(originalPrice),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: originalPriceColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
              decorationColor: Theme.of(context).colorScheme.onSurfaceVariant,
              decorationThickness: 1.5,
            ),
          ),

          const SizedBox(width: 8),

          // Discount badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: discountBackgroundColor ?? Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '$discountPercentage% OFF',
              style: TextStyle(
                fontSize: isTablet(context) ? 14 : 10.sp,
                fontWeight: FontWeight.w500,
                color: discountTextColor ?? Theme.of(context).colorScheme.error,
                height: 1.1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}