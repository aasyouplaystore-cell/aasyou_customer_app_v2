import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/my_orders/bloc/re_order/re_order_bloc.dart';
import 'package:aasyou/screens/my_orders/model/order_detail_model.dart';
import 'package:aasyou/screens/my_orders/model/order_status.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';

class OrderActionBar extends StatelessWidget {
  final OrderDetailData order;
  final OrderStatus status;
  final VoidCallback onReturnTap;

  const OrderActionBar({
    super.key,
    required this.order,
    required this.status,
    required this.onReturnTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _resolveActions();
    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _layoutButtons(context, actions),
        ),
      ),
    );
  }

  List<_OrderAction> _resolveActions() {
    final list = <_OrderAction>[];
    if (status == OrderStatus.delivered) {
      list.add(_OrderAction.reorder);
      list.add(_OrderAction.returnItems);
    } else if (status.allowsReorder) {
      list.add(_OrderAction.reorder);
    }
    if (status == OrderStatus.failed) {
      list.add(_OrderAction.retryPayment);
    }
    return list;
  }

  List<Widget> _layoutButtons(
    BuildContext context,
    List<_OrderAction> actions,
  ) {
    final widgets = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      final action = actions[i];
      widgets.add(
        Expanded(
          flex: 1,
          // flex: action.isPrimary ? 2 : 1,
          child: _buildButton(context, action),
        ),
      );
      if (i != actions.length - 1) {
        widgets.add(SizedBox(width: 8.w));
      }
    }
    return widgets;
  }

  Widget _buildButton(BuildContext context, _OrderAction action) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = _labelFor(action, l10n);

    if (action.isPrimary) {
      return CustomButton(
        onPressed: () => _handle(context, action),
        // style: ElevatedButton.styleFrom(
        //   backgroundColor: AppTheme.primaryColor,
        //   foregroundColor: Colors.white,
        //   elevation: 0,
        //   padding: EdgeInsets.symmetric(vertical: 12.h),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(8.r),
        //   ),
        // ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
        ),
      );
    }

    final destructive = action.isDestructive;
    final fg = destructive ? AppTheme.errorColor : scheme.onSurface;
    final border = destructive
        ? AppTheme.errorColor.withValues(alpha: 0.5)
        : scheme.outline;

    return OutlinedButton(
      onPressed: () => _handle(context, action),
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: border),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _labelFor(_OrderAction action, AppLocalizations? l10n) {
    switch (action) {
      case _OrderAction.reorder:
        return l10n?.actionReorder ?? 'Reorder';
      case _OrderAction.returnItems:
        return l10n?.actionReturn ?? 'Return';
      case _OrderAction.retryPayment:
        return l10n?.actionRetryPayment ?? 'Retry payment';
    }
  }

  void _handle(BuildContext context, _OrderAction action) {
    switch (action) {
      case _OrderAction.reorder:
        if (order.id != null) {
          context.read<ReOrderBloc>().add(
                ReOrderRequest(
                  orderId: order.id!,
                  orderItems: order.items,
                ),
              );
        }
        break;
      case _OrderAction.returnItems:
        onReturnTap();
        break;
      case _OrderAction.retryPayment:
        context.push(
          AppRoutes.paymentOptions,
          extra: {
            'totalAmount': double.tryParse(order.finalTotal ?? '0') ?? 0.0,
          },
        );
        break;
    }
  }
}

enum _OrderAction { reorder, returnItems, retryPayment }

extension on _OrderAction {
  bool get isPrimary {
    return this == _OrderAction.reorder ||
        this == _OrderAction.retryPayment;
  }

  bool get isDestructive {
    return this == _OrderAction.returnItems;
  }
}
