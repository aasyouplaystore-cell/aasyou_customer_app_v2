import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/router/app_routes.dart';

class RateExperienceTile extends StatelessWidget {
  final int orderId;
  final String orderSlug;
  final Future<void> Function() onRated;
  final double avgRating;

  const RateExperienceTile({
    super.key,
    required this.orderId,
    required this.orderSlug,
    required this.onRated,
    required this.avgRating,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _openRatingPage(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n?.ratingExperience ?? 'Rate your experience',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ...List.generate(5, (i) {
                final starIndex = i + 1;

                IconData icon;
                Color color;

                if (avgRating >= starIndex) {
                  // Full star
                  icon = TablerIcons.star_filled;
                  color = Colors.amber;
                } else if (avgRating >= starIndex - 0.5) {
                  // Half star
                  icon = TablerIcons.star_half_filled;
                  color = Colors.amber;
                } else {
                  // Empty star
                  icon = TablerIcons.star;
                  color = Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.35);
                }

                return Padding(
                  padding: EdgeInsets.only(left: 3.w),
                  child: Icon(
                    icon,
                    size: 16.sp,
                    color: color,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openRatingPage(BuildContext context) async {
    final result = await GoRouter.of(context).push(
      AppRoutes.rateYourExp,
      extra: {
        'orderSlug': orderSlug,
        'orderId': orderId,
      },
    );
    if (result == true) {
      await onRated();
    }
  }
}
