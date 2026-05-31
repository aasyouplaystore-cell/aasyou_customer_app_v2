import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/screens/my_orders/model/order_detail_model.dart';
import 'package:aasyou/screens/my_orders/model/order_status.dart';
import 'package:aasyou/screens/my_orders/widgets/rate_experience_tile.dart';

class OrderBelowHeroSection extends StatelessWidget {
  final OrderDetailData order;
  final OrderStatus status;
  final Future<void> Function() onRated;
  final double avgRating;

  const OrderBelowHeroSection({
    super.key,
    required this.order,
    required this.status,
    required this.onRated,
    required this.avgRating,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        final name = order.deliveryBoyName;
        if (name == null || name.trim().isEmpty) return const SizedBox.shrink();
        return const SizedBox.shrink();
        /*return DeliveryPartnerSection(
          name: name,
          phone: order.deliveryBoyPhone?.toString(),
          deliveryBoyProfile: order.deliveryBoyProfile,
        );*/
      case OrderStatus.delivered:
        if (order.id == null || order.slug == null) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            SizedBox(height: 10.h),
            RateExperienceTile(
              orderId: order.id!,
              orderSlug: order.slug!,
              onRated: onRated,
              avgRating: avgRating,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
