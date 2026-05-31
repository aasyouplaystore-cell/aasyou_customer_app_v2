import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/theme.dart';

enum OrderStatus {
  placed,
  confirmed,
  partiallyAccepted,
  preparing,
  readyForPickup,
  assigned,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  returned,
  failed,
  unknown,
}

extension OrderStatusX on OrderStatus {
  static OrderStatus fromString(String? raw) {
    if (raw == null) return OrderStatus.unknown;
    switch (raw.toLowerCase().trim()) {
      case 'placed':
      case 'pending':
      case 'awaiting_confirmation':
      case 'awaiting_store_response':
        return OrderStatus.placed;
      case 'partially_accepted':
        return OrderStatus.partiallyAccepted;
      case 'confirmed':
      case 'accepted':
        return OrderStatus.confirmed;
      case 'preparing':
      case 'processing':
      case 'packed':
        return OrderStatus.preparing;
      case 'ready_for_pickup':
      case 'readyforpickup':
      case 'ready-for-pickup':
        return OrderStatus.readyForPickup;
      case 'assigned':
      case 'driver_assigned':
      case 'delivery_assigned':
        return OrderStatus.assigned;
      case 'shipped':
      case 'dispatched':
        return OrderStatus.shipped;
      case 'out_for_delivery':
      case 'outfordelivery':
      case 'out-for-delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return OrderStatus.cancelled;
      case 'returned':
      case 'refunded':
        return OrderStatus.returned;
      case 'failed':
      case 'payment_failed':
        return OrderStatus.failed;
      default:
        return OrderStatus.unknown;
    }
  }

  bool get isInTransit =>
      this == OrderStatus.shipped || this == OrderStatus.outForDelivery;

  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.returned ||
      this == OrderStatus.failed;

  bool get isAwaiting =>
      this == OrderStatus.placed ||
      this == OrderStatus.partiallyAccepted ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.preparing;

  bool get allowsCancel =>
      this == OrderStatus.placed ||
      this == OrderStatus.partiallyAccepted ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.preparing;

  bool get allowsReturn => this == OrderStatus.delivered;

  bool get allowsReorder =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.returned;

  bool get allowsTrack =>
      this == OrderStatus.partiallyAccepted ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.preparing ||
      this == OrderStatus.readyForPickup ||
      this == OrderStatus.assigned ||
      this == OrderStatus.shipped ||
      this == OrderStatus.outForDelivery;

  IconData get icon {
    switch (this) {
      case OrderStatus.placed:
        return TablerIcons.clock;
      case OrderStatus.partiallyAccepted:
        return TablerIcons.alert_triangle;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return TablerIcons.package;
      case OrderStatus.readyForPickup:
        return TablerIcons.building_store;
      case OrderStatus.assigned:
        return TablerIcons.user_check;
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        return TablerIcons.truck_delivery;
      case OrderStatus.delivered:
        return TablerIcons.circle_check;
      case OrderStatus.cancelled:
        return TablerIcons.circle_x;
      case OrderStatus.returned:
        return TablerIcons.arrow_back_up;
      case OrderStatus.failed:
        return TablerIcons.alert_circle;
      case OrderStatus.unknown:
        return TablerIcons.help_circle;
    }
  }

  HeroPalette palette(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (this) {
      case OrderStatus.placed:
        return dark
            ? const HeroPalette(bg: Color(0xFF0C4A6E), fg: Color(0xFFBAE6FD), accent: Color(0xFF38BDF8))
            : const HeroPalette(bg: Color(0xFFE0F2FE), fg: Color(0xFF075985), accent: Color(0xFF0369A1));
      case OrderStatus.partiallyAccepted:
        return dark
            ? const HeroPalette(bg: Color(0xFF78350F), fg: Color(0xFFFCD34D), accent: Color(0xFFF59E0B),)
            : const HeroPalette(bg: Color(0xFFFEF3C7), fg: Color(0xFF78350F), accent: Color(0xFF92400E),);
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return dark
            ? const HeroPalette(bg: Color(0xFF134E4A), fg: Color(0xFF99F6E4), accent: Color(0xFF2DD4BF))
            : const HeroPalette(bg: Color(0xFFCCFBF1), fg: Color(0xFF134E4A), accent: Color(0xFF0F766E));
      case OrderStatus.readyForPickup:
        return dark
            ? const HeroPalette(bg: Color(0xFF065F46), fg: Color(0xFF6EE7B7), accent: Color(0xFF10B981))
            : const HeroPalette(bg: Color(0xFFD1FAE5), fg: Color(0xFF065F46), accent: Color(0xFF059669));
      case OrderStatus.assigned:
        return dark
            ? const HeroPalette(bg: Color(0xFF1E1B4B), fg: Color(0xFFA5B4FC), accent: Color(0xFF818CF8))
            : const HeroPalette(bg: Color(0xFFE0E7FF), fg: Color(0xFF1E1B4B), accent: Color(0xFF4338CA));
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        return dark
            ? const HeroPalette(bg: Color(0xFF78350F), fg: Color(0xFFFCD34D), accent: Color(0xFFF59E0B))
            : const HeroPalette(bg: Color(0xFFFEF3C7), fg: Color(0xFF78350F), accent: Color(0xFF92400E));
      case OrderStatus.delivered:
        return dark
            ? const HeroPalette(bg: Color(0xFF14532D), fg: Color(0xFF86EFAC), accent: Color(0xFF22C55E))
            : const HeroPalette(bg: Color(0xFFDCFCE7), fg: Color(0xFF14532D), accent: Color(0xFF166534));
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return dark
            ? const HeroPalette(bg: Color(0xFF881337), fg: Color(0xFFFDA4AF), accent: Color(0xFFF43F5E))
            : const HeroPalette(bg: Color(0xFFFFE4E6), fg: Color(0xFF881337), accent: Color(0xFF9F1239));
      case OrderStatus.returned:
        return dark
            ? const HeroPalette(bg: Color(0xFF4C1D95), fg: Color(0xFFC4B5FD), accent: Color(0xFF8B5CF6))
            : const HeroPalette(bg: Color(0xFFEDE9FE), fg: Color(0xFF4C1D95), accent: Color(0xFF5B21B6));
      case OrderStatus.unknown:
        return dark
            ? HeroPalette(
                bg: Theme.of(context).colorScheme.onPrimary,
                fg: Theme.of(context).colorScheme.onSurface,
                accent: AppTheme.primaryColor,
              )
            : HeroPalette(
                bg: Theme.of(context).colorScheme.onPrimary,
                fg: Theme.of(context).colorScheme.onSurface,
                accent: AppTheme.primaryColor,
              );
    }
  }
}

class HeroPalette {
  final Color bg;
  final Color fg;
  final Color accent;

  const HeroPalette({
    required this.bg,
    required this.fg,
    required this.accent,
  });
}
