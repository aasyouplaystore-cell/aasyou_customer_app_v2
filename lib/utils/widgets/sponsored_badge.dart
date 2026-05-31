import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../config/helper.dart';
import '../../l10n/app_localizations.dart';

enum SponsoredBadgeStyle { ribbon, chip }

class SponsoredBadge extends StatelessWidget {
  final SponsoredBadgeStyle style;
  const SponsoredBadge({super.key, this.style = SponsoredBadgeStyle.ribbon});

  @override
  Widget build(BuildContext context) {
    final String label =
        AppLocalizations.of(context)?.sponsored ?? 'Sponsored';

    final bool isChip = style == SponsoredBadgeStyle.chip;

    if (isChip) return _buildChip(context, label);
    return _buildRibbon(context, label);
  }

  Widget _buildRibbon(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(4.r),
          bottomStart: Radius.circular(4.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.ad,
            size: isTablet(context) ? 16 : 14.sp,
            color: Colors.white,
          ),
          /*Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTablet(context) ? 12 : 8.sp,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(3.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon(TablerIcons.ad, size: 10.sp, color: Colors.white),
            // SizedBox(width: 3.w),
            Flexible(
              child: Text(
                'Ad',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                  // letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
