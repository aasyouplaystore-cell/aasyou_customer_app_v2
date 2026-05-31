import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/my_orders/model/order_detail_model.dart';
import 'package:aasyou/screens/my_orders/model/order_status.dart';
import 'package:intl/intl.dart';

class OrderStatusHeroCard extends StatelessWidget {
  final OrderDetailData order;
  final OrderStatus status;

  const OrderStatusHeroCard({
    super.key,
    required this.order,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final palette = status.palette(context);
    final l10n = AppLocalizations.of(context);

    final headline = _buildHeadline(context, l10n);
    final secondary = _buildSecondary(context, l10n);
    final pill = _statusLabel(l10n);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  pill,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: palette.fg,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (order.id != null)
                Text(
                  '#${order.id}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: palette.accent,
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            headline,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: palette.fg,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            secondary,
            style: TextStyle(
              fontSize: 11.sp,
              color: palette.accent,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations? l10n) {
    if (l10n == null) return status.name.toUpperCase();
    switch (status) {
      case OrderStatus.placed:
        return l10n.statusPlaced;
      case OrderStatus.partiallyAccepted:
        return l10n.statusPartiallyAccepted;
      case OrderStatus.confirmed:
        return l10n.statusConfirmed;
      case OrderStatus.preparing:
        return l10n.statusPreparing;
      case OrderStatus.readyForPickup:
        return l10n.statusReadyForPickup;
      case OrderStatus.assigned:
        return l10n.statusAssigned;
      case OrderStatus.shipped:
        return l10n.statusShipped;
      case OrderStatus.outForDelivery:
        return l10n.statusOutForDelivery;
      case OrderStatus.delivered:
        return l10n.statusDelivered;
      case OrderStatus.cancelled:
        return l10n.statusCancelled;
      case OrderStatus.returned:
        return l10n.statusReturned;
      case OrderStatus.failed:
        return l10n.statusFailed;
      case OrderStatus.unknown:
        return status.name.toUpperCase();
    }
  }

  String _buildHeadline(BuildContext context, AppLocalizations? l10n) {
    final eta = _formattedEta();
    final isLate = _isRunningLate();

    if (isLate && status.isInTransit) {
      return l10n?.heroRunningLate ?? 'Running a bit late';
    }

    switch (status) {
      case OrderStatus.placed:
        return l10n?.heroAwaitingConfirmation ?? 'Awaiting confirmation';
      case OrderStatus.partiallyAccepted:
        return l10n?.heroPartiallyAccepted ?? 'Some items unavailable';
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        if (eta != null) {
          return l10n?.heroArrivingBy(eta) ?? 'Arriving by $eta';
        }
        return l10n?.heroOnTheWay ?? 'On the way';
      case OrderStatus.readyForPickup:
        return l10n?.heroReadyForPickup ?? 'Your order is ready for pickup';
      case OrderStatus.assigned:
        return l10n?.heroAssigned ?? 'Delivery partner assigned';
      case OrderStatus.delivered:
        return _wasDeliveredOnTime()
            ? (l10n?.heroDeliveredOnTime ?? 'Delivered on time')
            : (l10n?.heroDelivered ?? 'Delivered');
      case OrderStatus.cancelled:
        return l10n?.heroOrderCancelled ?? 'Order cancelled';
      case OrderStatus.returned:
        return l10n?.heroReturnedAndRefunded ?? 'Returned & refunded';
      case OrderStatus.failed:
        return l10n?.heroPaymentFailed ?? 'Payment failed';
      case OrderStatus.unknown:
        return order.status ?? '';
    }
  }

  String _buildSecondary(BuildContext context, AppLocalizations? l10n) {
    final placedTime = _formattedTime(order.createdAt);
    final eta = _formattedEta();

    switch (status) {
      case OrderStatus.placed:
        if (placedTime != null && eta != null) {
          return l10n?.secondaryPlacedAndEta(placedTime, eta) ??
              'Placed $placedTime · ETA $eta';
        }
        return l10n?.secondaryUsuallyAccepted ?? 'Usually accepted in 2 min';
      case OrderStatus.partiallyAccepted:
        final rejectedCount = order.items
            .where((i) => i.status == 'rejected' || i.status == 'cancelled')
            .length;
        final acceptedCount = order.items
            .where((i) => i.status == 'accepted')
            .length;
        final preparingCount = order.items
            .where((i) => i.status == 'preparing')
            .length;
        final pendingCount = order.items
            .where((i) =>
                i.status == 'pending' ||
                i.status == 'awaiting_store_response')
            .length;
        final parts = <String>[
          if (acceptedCount > 0)
            l10n?.itemCountAccepted(acceptedCount) ?? '$acceptedCount accepted',
          if (preparingCount > 0)
            l10n?.itemCountPreparing(preparingCount) ?? '$preparingCount preparing',
          if (rejectedCount > 0)
            l10n?.itemCountRejected(rejectedCount) ?? '$rejectedCount rejected',
          if (pendingCount > 0)
            l10n?.itemCountPending(pendingCount) ?? '$pendingCount pending',
        ];
        if (parts.isNotEmpty) return parts.join(' · ');
        return l10n?.secondaryPartialItems(order.items.length) ??
            '${order.items.length} items';
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return l10n?.heroStorePreparing ?? 'Store is preparing your order';
      case OrderStatus.readyForPickup:
        return l10n?.secondaryReadyForPickup ?? 'Head to the store to collect your order';
      case OrderStatus.assigned:
        return l10n?.secondaryAssigned ?? 'A delivery partner is heading to pick up your order';
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        return l10n?.heroOnTheWay ?? 'On the way';
      case OrderStatus.delivered:
        final date = _formattedDate(order.updatedAt ?? order.createdAt);
        final time = _formattedTime(order.updatedAt ?? order.createdAt);
        if (date != null && time != null) {
          return l10n?.secondaryDeliveredOn(date, time) ?? '$date · $time';
        }
        return '';
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        final date = _formattedDate(order.updatedAt ?? order.createdAt);
        if (date != null) {
          return l10n?.secondaryCancelledByYou(date) ?? 'Cancelled · $date';
        }
        return '';
      case OrderStatus.returned:
        final date = _formattedDate(order.updatedAt ?? order.createdAt);
        final count = order.items.length;
        if (date != null) {
          return l10n?.secondaryItemsReturned(count, date) ??
              '$count items returned · $date';
        }
        return '';
      case OrderStatus.unknown:
        return '';
    }
  }

  bool _isRunningLate() {
    final eta = _etaDateTime();
    if (eta == null) return false;
    return DateTime.now().isAfter(eta);
  }

  bool _wasDeliveredOnTime() {
    final eta = _etaDateTime();
    final deliveredAt = order.updatedAt;
    if (eta == null || deliveredAt == null) return true;
    final delivered = DateTime.tryParse(deliveredAt);
    if (delivered == null) return true;
    return delivered
        .isBefore(eta.add(const Duration(minutes: 15)));
  }

  DateTime? _etaDateTime() {
    final created = order.createdAt;
    final minutes = order.estimatedDeliveryTime;
    if (created == null || minutes == null) return null;
    final base = DateTime.tryParse(created);
    if (base == null) return null;
    return base.add(Duration(minutes: minutes));
  }

  String? _formattedEta() {
    final eta = _etaDateTime();
    if (eta == null) return null;
    return DateFormat('h:mm a').format(eta.toLocal());
  }

  String? _formattedTime(String? raw) {
    if (raw == null) return null;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return null;
    return DateFormat('h:mm a').format(dt.toLocal());
  }

  String? _formattedDate(String? raw) {
    if (raw == null) return null;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return null;
    return DateFormat('d MMM').format(dt.toLocal());
  }
}
