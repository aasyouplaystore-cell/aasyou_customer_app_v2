import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/my_orders/model/order_detail_model.dart';
import 'package:aasyou/screens/my_orders/widgets/order_items_card.dart';

Future<void> showOrderItemsBottomSheet({
  required BuildContext context,
  required List<OrderItems> items,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OrderItemsBottomSheetContent(items: items),
  );
}

class _OrderItemsBottomSheetContent extends StatelessWidget {
  final List<OrderItems> items;
  const _OrderItemsBottomSheetContent({required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                child: Row(
                  children: [
                    Text(
                      l10n?.itemsCount(items.length) ??
                          '${items.length} items',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: 20.sp,
                      color: scheme.onSurfaceVariant,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 24.h),
                  child: OrderItemsCard(
                    items: items,
                    totalItems: items.length.toString(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
