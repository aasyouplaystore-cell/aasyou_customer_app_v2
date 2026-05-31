import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/utils/widgets/product_indicator.dart';
import 'package:aasyou/utils/widgets/shake_widget.dart';

import '../../config/helper.dart';

class CustomAddonSection extends StatefulWidget {
  final AddonGroup group;

  /// IDs of items currently selected inside this group.
  final Set<int> selectedItemIds;

  /// Called whenever the selection changes.
  final ValueChanged<Set<int>> onChanged;

  /// When true AND the group is required, the inline error message is shown.
  final bool showError;

  /// Monotonically-increasing counter that re-triggers the shake animation.
  final int shakeSeed;

  const CustomAddonSection({
    super.key,
    required this.group,
    required this.selectedItemIds,
    required this.onChanged,
    this.showError = false,
    this.shakeSeed = 0,
  });

  @override
  State<CustomAddonSection> createState() => _CustomAddonSectionState();
}

class _CustomAddonSectionState extends State<CustomAddonSection> {
  final GlobalKey<ShakeWidgetState> _shakeKey =
      GlobalKey<ShakeWidgetState>();

  bool get _isSingle =>
      widget.group.selectionType.toLowerCase() == 'single';

  bool get _shouldShowError => widget.showError && widget.group.isRequired;

  Color _mutedTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6);

  @override
  void didUpdateWidget(covariant CustomAddonSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool wasShowingError =
        oldWidget.showError && oldWidget.group.isRequired;
    final bool seedChanged = widget.shakeSeed != oldWidget.shakeSeed;

    if (_shouldShowError && (!wasShowingError || seedChanged)) {
      HapticFeedback.heavyImpact();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _shakeKey.currentState?.shake();
      });
    }
  }

  void _handleTap(AddonItem item) {
    if (!item.isAvailable) return;

    final next = Set<int>.from(widget.selectedItemIds);
    if (_isSingle) {
      if (next.contains(item.id)) {
        if (!widget.group.isRequired) next.remove(item.id);
      } else {
        next
          ..clear()
          ..add(item.id);
      }
    } else {
      // Multiple selection: toggle.
      if (next.contains(item.id)) {
        next.remove(item.id);
      } else {
        next.add(item.id);
      }
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final group = widget.group;

    if (group.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              group.title.isEmpty
                                  ? (l10n?.addonsTitle ?? 'Add-ons')
                                  : group.title,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ),
                          if (group.isRequired) ...[
                            SizedBox(width: 8.w),
                            _buildRequiredBadge(context),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _buildHint(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: _mutedTextColor(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Shaking error message between the title and the hint.
                      ShakeWidget(
                        key: _shakeKey,
                        shakeOffset: 10.0,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          alignment: Alignment.topLeft,
                          child: _shouldShowError
                              ? Padding(
                            padding: EdgeInsets.only(
                                top: 4.h, bottom: 2.h),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .addonGroupRequiredError,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          )
                              : const SizedBox(
                              width: double.infinity, height: 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Items card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              // border: _shouldShowError
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: group.items.length,
              separatorBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              itemBuilder: (context, index) =>
                  _buildAddonRow(context, group.items[index]),
            ),
          ),
        ],
      ),
    );
  }

  String _buildHint() {
    final l10n = AppLocalizations.of(context);
    if (_isSingle) {
      return widget.group.isRequired
          ? (l10n?.addonHintSelectOneRequired ?? 'Select 1 (required)')
          : (l10n?.addonHintSelectOne ?? 'Select any 1');
    }
    return widget.group.isRequired
        ? (l10n?.addonHintSelectAtLeastOneRequired ??
            'Select at least 1 (required)')
        : (l10n?.addonHintSelectAny ?? 'Select any');
  }

  Widget _buildRequiredBadge(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        l10n?.addonRequiredBadge ?? 'Required',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildAddonRow(BuildContext context, AddonItem item) {
    final theme = Theme.of(context);
    final bool isSelected = widget.selectedItemIds.contains(item.id);
    final bool isDisabled = !item.isAvailable;

    final titleStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: isDisabled
          ? _mutedTextColor(context)
          : theme.colorScheme.tertiary,
      decoration:
          isDisabled ? TextDecoration.lineThrough : TextDecoration.none,
    );

    final priceStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: isDisabled
          ? _mutedTextColor(context)
          : theme.colorScheme.tertiary,
    );

    return Opacity(
      opacity: isDisabled ? 0.55 : 1.0,
      child: InkWell(
        onTap: isDisabled ? null : () => _handleTap(item),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              productIndicator(item.indicator),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.title, style: titleStyle),
                    if (isDisabled)
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          AppLocalizations.of(context)?.addonUnavailable ??
                              'Unavailable',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.error
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (item.price > 0)
                Text(
                  '+ ${AppHelpers.currency}${formatPrice(item.price, locale: AppHelpers.defaultLocalCurrency)}',
                  style: priceStyle,
                ),
              SizedBox(width: 12.w),
              _buildSelectorControl(context, item, isSelected, isDisabled),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorControl(
    BuildContext context,
    AddonItem item,
    bool isSelected,
    bool isDisabled,
  ) {
    final theme = Theme.of(context);

    if (_isSingle) {
      // Radio for single-selection groups
      return Radio<int>(
        value: item.id,
        groupValue: widget.selectedItemIds.isEmpty
            ? null
            : widget.selectedItemIds.first,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        activeColor: AppTheme.primaryColor,
        onChanged: isDisabled ? null : (_) => _handleTap(item),
      );
    }

    // Checkbox for multiple-selection groups
    return Checkbox(
      value: isSelected,
      activeColor: AppTheme.primaryColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(
        color: theme.colorScheme.outline,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r),
      ),
      onChanged: isDisabled ? null : (_) => _handleTap(item),
    );
  }
}
