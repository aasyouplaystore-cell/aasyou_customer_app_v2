import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/my_orders/model/order_status.dart';

class OrderCancelTile extends StatelessWidget {
  final OrderStatus status;
  final VoidCallback onCancelTap;
  final bool allowCancelInTransit;

  const OrderCancelTile({
    super.key,
    required this.status,
    required this.onCancelTap,
    this.allowCancelInTransit = false,
  });

  bool get _isVisible {
    if (status.allowsCancel) return true;
    if (allowCancelInTransit && status.isInTransit) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isLtr = Directionality.of(context) == TextDirection.ltr;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onCancelTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                TablerIcons.circle_x,
                size: 16.sp,
                color: AppTheme.errorColor,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  l10n?.actionCancelOrder ?? 'Cancel order',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
              Icon(
                isLtr
                    ? TablerIcons.chevron_right
                    : TablerIcons.chevron_left,
                size: 16.sp,
                color: AppTheme.errorColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
