import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/my_orders/model/order_detail_model.dart';
import 'package:aasyou/screens/my_orders/widgets/order_items_bottom_sheet.dart';
import 'package:aasyou/screens/my_orders/widgets/order_items_row.dart';

const int _kVisibleCount = 5;
const int _kCapThreshold = 7;

class OrderItemsPreviewCard extends StatelessWidget {
  final List<OrderItems> items;
  final String? subtotal;

  const OrderItemsPreviewCard({
    super.key,
    required this.items,
    this.subtotal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final showCap = items.length >= _kCapThreshold;
    final visible = showCap ? items.take(_kVisibleCount).toList() : items;
    final hidden = showCap ? items.length - _kVisibleCount : 0;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.itemsCount(items.length) ?? '${items.length} items',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
              if (subtotal != null && subtotal!.isNotEmpty)
                Text(
                  '${l10n?.subtotalLabel ?? 'Subtotal'} ${AppHelpers.currency}$subtotal',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          ...List.generate(visible.length, (i) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: scheme.outline,
                    width: 0.5,
                  ),
                ),
              ),
              child: OrderItemsRow(
                item: visible[i],
                onTap: () => showOrderItemsBottomSheet(
                  context: context,
                  items: items,
                ),
              ),
            );
          }),
          if (showCap)
            _ViewMoreRow(
              hiddenCount: hidden,
              hiddenItems: items.skip(_kVisibleCount).toList(),
              onTap: () => showOrderItemsBottomSheet(
                context: context,
                items: items,
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewMoreRow extends StatelessWidget {
  final int hiddenCount;
  final List<OrderItems> hiddenItems;
  final VoidCallback onTap;

  const _ViewMoreRow({
    required this.hiddenCount,
    required this.hiddenItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final preview = hiddenItems.take(3).toList();
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(top: 10.h, bottom: 2.h),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: scheme.outline, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _StackedThumbs(items: preview),
                SizedBox(width: 8.w),
                Text(
                  l10n?.viewMoreItems(hiddenCount) ??
                      'View $hiddenCount more items',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            Icon(
              TablerIcons.chevron_right,
              size: 14.sp,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _StackedThumbs extends StatelessWidget {
  final List<OrderItems> items;
  const _StackedThumbs({required this.items});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (items.isEmpty) return const SizedBox.shrink();

    final stack = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final url = items[i].product?.image ?? '';
      stack.add(Padding(
        padding: EdgeInsetsDirectional.only(start: i * 14.w),
        child: Container(
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: scheme.surface, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: url.trim().isEmpty
              ? Icon(
                  TablerIcons.package,
                  size: 12.sp,
                  color: scheme.onSurfaceVariant,
                )
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  memCacheWidth: 70,
                  errorWidget: (_, __, ___) => Icon(
                    TablerIcons.package,
                    size: 12.sp,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
        ),
      ));
    }
    return SizedBox(
      width: 22.w + (stack.length - 1) * 14.w,
      height: 22.w,
      child: Stack(children: stack),
    );
  }
}
