import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/product_detail_page/bloc/product_review_bloc/product_review_bloc.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/screens/product_detail_page/widgets/rating_info_card.dart';
import 'package:aasyou/screens/product_detail_page/widgets/review_rating_card.dart';

/// Customer reviews section for the product detail page.
class ProductReviewsSection extends StatelessWidget {
  final ProductData product;

  const ProductReviewsSection({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ProductReviewBloc, ProductReviewState>(
      builder: (BuildContext context, ProductReviewState state) {
        if (state is ProductReviewLoaded) {
          if (state.productReview.first.data.totalReviews > 0 ||
              state.productReview.first.data.reviews.isNotEmpty) {
            return Column(
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.r),
                  ),
                  margin: EdgeInsets.only(left: 0.w, right: 0.w, top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10.w,
                          right: 10.w,
                          top: 10.w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.customerReviews,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                GoRouter.of(context).push(
                                  AppRoutes.reviewRatingPage,
                                  extra: {'productSlug': product.slug},
                                );
                              },
                              child: Text(
                                l10n.seeAll,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.productReview.first.data.totalReviews > 0)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 8.h),
                          child: RatingInfoCard(
                            reviewModel: state.productReview.first,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0.w,
                          vertical: 12.w,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(right: 12.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: state.productReview.first.data.reviews
                                .take(5)
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              final int index = entry.key;
                              final review = entry.value;
                              return SizedBox(
                                width: 280.w,
                                child: ReviewRatingCard(
                                  rating: review.rating.toDouble(),
                                  date: review.createdAt,
                                  reviewText: review.comment,
                                  index: index,
                                  images: review.reviewImages,
                                  maxLines: 10,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            );
          }
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
