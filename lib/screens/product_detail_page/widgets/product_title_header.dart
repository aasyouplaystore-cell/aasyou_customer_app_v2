import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/settings_data_instance.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/screens/product_detail_page/widgets/price_row_widget.dart';
import 'package:aasyou/utils/widgets/custom_delivery_time_widget.dart';
import 'package:aasyou/utils/widgets/sponsored_badge.dart';

import '../../../l10n/app_localizations.dart';

/// The top section of the product detail page: title, estimated delivery.
class ProductTitleHeader extends StatelessWidget {
  final ProductData product;
  final ProductVariants activeVariant;
  final ProductVariants currentVariant;

  const ProductTitleHeader({
    super.key,
    required this.product,
    required this.activeVariant,
    required this.currentVariant,
  });

  @override
  Widget build(BuildContext context) {
    final lowStockLimit =
        int.parse(SettingsData.instance.system!.lowStockLimit!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet(context) ? 24 : 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 4,
                start: 4,
              ),
              child: DeliveryTimeWidget(
                time: product.estimatedDeliveryTime.toString(),
              ),
            ),
          ],
        ),
        if (product.isSponsored)
          Padding(
            padding: EdgeInsets.only(top: 4.h, bottom: 2.h),
            child: const SponsoredBadge(style: SponsoredBadgeStyle.chip),
          ),
        /*if (product.isRecommended)
          Padding(
            padding: EdgeInsets.only(top: 4.h, bottom: 2.h),
            child: const RecommendBadge(style: RecommendBadgeStyle.chip),
          ),*/
        if (currentVariant.stock <= lowStockLimit && currentVariant.stock > 0) ...[
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                AppLocalizations.of(context)!.hurryOnlyLeft(currentVariant.stock),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        if (int.parse(product.itemCountInCart) > 0) ...[
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  '🛍️ ${product.itemCountInCart} ${AppLocalizations.of(context)!.inCart}',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            RatingBar.builder(
              initialRating:
                  double.parse(product.ratings.toString()),
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 18,
              itemBuilder: (context, _) => const Icon(
                AppTheme.ratingStarIconFilled,
                color: AppTheme.ratingStarColor,
              ),
              ignoreGestures: true,
              onRatingUpdate: (rating) {},
            ),
            const SizedBox(width: 8),
            Text(
              '${product.ratings}/5 ',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: 0.8),
              ),
            ),
            Text('(${product.ratingCount})'),
          ],
        ),
        SizedBox(height: 10.h),
        PriceRowWidget(
          originalPrice: activeVariant.price.toDouble(),
          salePrice: activeVariant.specialPrice.toDouble(),
          fontSize: 12.sp,
          originalFontSize: 10.sp,
          discountFontSize: 8.sp,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }


}
