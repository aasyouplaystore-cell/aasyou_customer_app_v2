import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';

/// Expandable "View product details" section containing a striped.
class ProductDescriptionSection extends StatelessWidget {
  final ProductData product;

  const ProductDescriptionSection({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      expansionAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        reverseDuration: Duration(milliseconds: 250),
      ),
      title: Text(
        l10n.viewProductDetails,
        style: TextStyle(
          fontSize: isTablet(context) ? 18 : 14.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      collapsedIconColor: Theme.of(context).colorScheme.tertiary,
      iconColor: Theme.of(context).colorScheme.tertiary,
      initiallyExpanded: false,
      tilePadding: EdgeInsets.symmetric(horizontal: 0.w),
      childrenPadding: EdgeInsets.symmetric(horizontal: 0.w),
      shape: const Border(),
      children: [
        Divider(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          thickness: 1,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
          child: Column(
            children: _buildSpecTableRows(context, product, l10n),
          ),
        ),
        const SizedBox(height: 5,),
        Html(
          data: product.shortDescription,
          shrinkWrap: true,
        ),
        Html(
          data: product.description,
          shrinkWrap: true,
        ),
      ],
    );
  }

  List<Widget> _buildSpecTableRows(
    BuildContext context,
    ProductData product,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.tertiary;
    final labelColor = textColor.withValues(alpha: 0.75);
    final valueColor = textColor.withValues(alpha: 0.95);

    final List<MapEntry<String, String>> specs = [];

    if (product.brand.isNotEmpty) {
      specs.add(MapEntry(l10n.brand, product.brandName));
    }
    if (product.category.isNotEmpty) {
      specs.add(MapEntry(l10n.category, product.categoryName));
    }
    specs.add(MapEntry(
      l10n.packOf,
      '${product.quantityStepSize} ${product.quantityStepSize > 1 ? 'Units' : 'Unit'}',
    ));

    if (product.madeIn.isNotEmpty) {
      specs.add(MapEntry(l10n.madeIn, product.madeIn));
    }
    if (product.indicator.isNotEmpty) {
      specs.add(MapEntry(
        l10n.indicator,
        removeUnderscores(capitalizeFirstLetter(product.indicator)),
      ));
    }

    // Guarantee & Warranty
    final guarantee = product.guaranteePeriod.toString();
    if (guarantee.isNotEmpty && guarantee != '0') {
      specs.add(MapEntry(l10n.guaranteePeriod, guarantee));
    }

    final warranty = product.warrantyPeriod.toString();
    if (warranty.isNotEmpty && warranty != '0') {
      specs.add(MapEntry(l10n.warrantyPeriod, warranty));
    }

    // Returnable
    final isReturnable = product.isReturnable;
    specs.add(MapEntry(
      l10n.returnable,
      isReturnable ? l10n.yes : l10n.na,
    ));

    // All custom fields
    for (final field in product.customFields) {
      final valueStr = field.value?.toString().trim() ?? '';
      if (valueStr.isNotEmpty) {
        specs.add(MapEntry(field.key, valueStr));
      }
    }

    if (specs.isEmpty) {
      return [const SizedBox.shrink()];
    }

    // Build striped table rows
    return List.generate(specs.length, (index) {
      final entry = specs[index];
      final isEven = index % 2 == 0;
      final isLast = index == specs.length - 1;

      return Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isEven
              ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
              : theme.colorScheme.onPrimary.withValues(alpha: 0.3),
          border: isLast
              ? Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                  left: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                  right: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                )
              : Border(
                  top: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                  left: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                  right: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label column
            SizedBox(
              width: 140.w,
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Value column
            Expanded(
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: valueColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
