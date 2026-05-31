import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/router/app_routes.dart';

class OrderHelpLink extends StatelessWidget {
  const OrderHelpLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: TextButton(
        onPressed: () => context.push(AppRoutes.supportPage),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          l10n?.needHelpWithOrder ?? 'Need help with this order?',
          style: TextStyle(
            fontSize: 11.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
