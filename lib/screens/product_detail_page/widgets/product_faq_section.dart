import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/product_detail_page/bloc/product_faq_bloc/product_faq_bloc.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';

/// Product FAQ (Q&A) section.
class ProductFaqSection extends StatelessWidget {
  final ProductData product;

  const ProductFaqSection({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ProductFAQBloc, ProductFAQState>(
      builder: (BuildContext context, ProductFAQState state) {
        if (state is ProductFAQLoaded) {
          final faqData = state.productData.first.faqs;
          if (faqData.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.r),
                ),
                margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
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
                            l10n.questionAndAnswers,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              GoRouter.of(context).push(
                                AppRoutes.faqPage,
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.w,
                        vertical: 12.w,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            faqData.length > 5 ? 5 : faqData.length,
                            (index) {
                              final qa = faqData[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == (faqData.length - 1)
                                      ? 0.w
                                      : 12.w,
                                  left: index == 0 ? 12.w : 0.w,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    GoRouter.of(context).push(
                                      AppRoutes.faqPage,
                                      extra: {'productSlug': product.slug},
                                    );
                                  },
                                  child: _QaItem(
                                    question: qa.question,
                                    answer: qa.answer,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _QaItem extends StatelessWidget {
  final String question;
  final String answer;

  const _QaItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.w,
      constraints: BoxConstraints(minHeight: 135.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Question Section (Top Partition)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainer
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11.r),
                topRight: Radius.circular(11.r),
              ),
            ),
            child: Text(
              question,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
          // Divider
          Container(
            width: double.infinity,
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w300,
                  height: 1.4,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
