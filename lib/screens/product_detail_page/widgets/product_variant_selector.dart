import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/utils/widgets/price_utils.dart';
import '../../../utils/widgets/dominant_colors.dart';

class ProductVariantSelector extends StatelessWidget {
  final String label;
  final String attributeSlug;
  final String variantType;
  final SwatchValues? selectedValue;
  final ValueChanged<SwatchValues> onSelected;
  final List<SwatchValues> productAttributes;
  final List<ProductVariants> variants;

  const ProductVariantSelector({
    super.key,
    required this.label,
    required this.attributeSlug,
    required this.variantType,
    required this.selectedValue,
    required this.onSelected,
    required this.productAttributes,
    required this.variants,
  });

  ProductVariants? _findVariantForSwatch(SwatchValues swatch) {
    try {
      return variants.firstWhere((v) {
        final attrValue = v.attributes[attributeSlug];
        return attrValue?.toString().toLowerCase().trim() ==
            swatch.value.toString().toLowerCase().trim();
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isColor = variantType == 'color';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet(context) ? 20 : 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 10.h),
        isColor ? _buildColorSwatches(context) : _buildTextVariantCards(context),
        SizedBox(height: 5.h),
      ],
    );
  }

  Widget _buildColorSwatches(BuildContext context) {
    return SizedBox(
      height: 35.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productAttributes.length,
        itemBuilder: (BuildContext context, int index) {
          final currentValue = productAttributes[index];
          final isSelected = selectedValue == currentValue;
          final color = getColorFromHex(currentValue.swatch);
          final matchedVariant = _findVariantForSwatch(currentValue);
          final isOutOfStock = matchedVariant != null && matchedVariant.stock <= 0;

          return GestureDetector(
            onTap: isOutOfStock ? null : () => onSelected(currentValue),
            child: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Opacity(
                opacity: isOutOfStock ? 0.4 : 1.0,
                child: Container(
                  width: 35.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Theme.of(context).colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Icon(
                            Icons.check,
                            size: 16.sp,
                            color: (color?.computeLuminance() ?? 1.0) < 0.5
                                ? Colors.white
                                : Colors.black87,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextVariantCards(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: productAttributes.map((currentValue) {
        final isSelected = selectedValue == currentValue;
        final matchedVariant = _findVariantForSwatch(currentValue);
        final isOutOfStock =
            matchedVariant != null && matchedVariant.stock <= 0;

        final double? price = matchedVariant?.price.toDouble();
        final double? salePrice = matchedVariant?.specialPrice.toDouble();
        final bool hasDiscount =
            price != null && salePrice != null && PriceUtils.hasDiscount(price, salePrice);
        final int discountPct = hasDiscount
            ? PriceUtils.calculateDiscountPercentage(price, salePrice)
            : 0;
        final String displayPrice = salePrice != null && salePrice > 0
            ? PriceUtils.formatPrice(salePrice)
            : (price != null ? PriceUtils.formatPrice(price) : '');


        return GestureDetector(
          onTap: isOutOfStock ? null : () => onSelected(currentValue),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            constraints: BoxConstraints(minWidth: 80.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isOutOfStock
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.08)
                      : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isOutOfStock
                    ? theme.colorScheme.outline.withValues(alpha: 0.3)
                    : isSelected
                        ? AppTheme.primaryColor
                        : theme.colorScheme.outline.withValues(alpha: 0.6),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Opacity(
              opacity: isOutOfStock ? 0.5 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentValue.value,
                    style: TextStyle(
                      fontSize: isTablet(context) ? 16 : 13.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : theme.colorScheme.tertiary,
                    ),
                  ),
                  if (displayPrice.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      displayPrice,
                      style: TextStyle(
                        fontSize: isTablet(context) ? 14 : 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : theme.colorScheme.tertiary,
                      ),
                    ),
                    if (hasDiscount) ...[
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            PriceUtils.formatPrice(price),
                            style: TextStyle(
                              fontSize: isTablet(context) ? 11 : 9.sp,
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$discountPct% off',
                            style: TextStyle(
                              fontSize: isTablet(context) ? 11 : 9.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  if (isOutOfStock) ...[
                    SizedBox(height: 4.h),
                    Text(
                      l10n.outOfStock,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.error.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
