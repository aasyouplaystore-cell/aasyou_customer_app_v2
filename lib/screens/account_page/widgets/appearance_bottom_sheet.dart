import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:spring_bottom_sheet/spring_bottom_sheet.dart';
import '../../../bloc/theme_bloc/theme_bloc.dart';
import '../../../bloc/theme_bloc/theme_event.dart';
import '../../../config/helper.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/theme_switcher_provider.dart';

class AppearanceBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (sheetContext) => SpringBottomSheet(
        child: _AppearanceSheetContent(parentContext: context),
      ),
    );
  }
}

class _AppearanceSheetContent extends StatelessWidget {
  const _AppearanceSheetContent({required this.parentContext});

  final BuildContext parentContext;

  void _applyTheme(BuildContext context, ThemeMode mode) {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    context.read<ThemeBloc>().add(ThemeChanged(mode));
    ThemeSwitcherProvider.maybeOf(parentContext)
        ?.changeTheme(AppTheme.resolveFromMode(mode, brightness));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentMode = context.read<ThemeBloc>().state;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            l10n?.appearance ?? 'Appearance',
            style: TextStyle(
              fontSize: isTablet(context) ? 20 : 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _ThemeCard(
                  label: l10n?.systemMode ?? 'System',
                  icon: TablerIcons.contrast,
                  iconBgColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  iconColor: AppTheme.primaryColor,
                  isSelected: currentMode == ThemeMode.system,
                  onTap: () => _applyTheme(context, ThemeMode.system),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ThemeCard(
                  label: l10n?.lightMode ?? 'Light',
                  icon: TablerIcons.sun,
                  iconBgColor: const Color(0xFFFFF8E1),
                  iconColor: AppTheme.ratingStarColor,
                  isSelected: currentMode == ThemeMode.light,
                  onTap: () => _applyTheme(context, ThemeMode.light),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ThemeCard(
                  label: l10n?.darkMode ?? 'Dark',
                  icon: TablerIcons.moon,
                  iconBgColor: AppTheme.mainDarkBackgroundColor,
                  iconColor: const Color(0xFFA5B4FC),
                  isSelected: currentMode == ThemeMode.dark,
                  onTap: () => _applyTheme(context, ThemeMode.dark),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24.h),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.07)
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet(context) ? 14 : 12.sp,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primaryColor
                    : Theme.of(context).colorScheme.tertiary,
              ),
            ),
            SizedBox(height: 6.h),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}