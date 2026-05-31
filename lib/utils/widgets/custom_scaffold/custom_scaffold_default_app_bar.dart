import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/helper.dart';

class CustomScaffoldDefaultAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const CustomScaffoldDefaultAppBar({
    super.key,
    this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary,
        fontSize: isTablet(context) ? 24 : 16.sp,
      ),
      actions: actions,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor:
          Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.2),
    );
  }
}
