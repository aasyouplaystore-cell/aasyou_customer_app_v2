import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/my_orders/model/delivery_tracking_model.dart';

class DeliveryStatusHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isDelivered;
  final DeliveryBoyTrackingModel? currentTracking;

  const DeliveryStatusHeader({
    super.key,
    required this.isDelivered,
    required this.currentTracking,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  String _getStatusText(String? status) {
    if (status == null || status.isEmpty) return 'Tracking Order';
    final result = status.replaceAll('_', ' ').replaceAll('-', ' ');
    if (result.isEmpty) return 'Tracking Order';
    return result[0].toUpperCase() + result.substring(1).toLowerCase();
  }

  String _getETAText() {
    final eta = currentTracking?.data?.order?.estimatedDeliveryTime;
    if (eta == null || eta == 0) return 'shortly';
    return '$eta minutes';
  }

  @override
  Widget build(BuildContext context) {
    final orderStatus = currentTracking?.data?.order?.status;
    final displayDelivered = isDelivered || orderStatus == 'delivered';

    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      title: Text(
        displayDelivered ? 'Order Delivered' : _getStatusText(orderStatus),
        style: const TextStyle(fontSize: 15, color: Colors.white),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          TablerIcons.arrow_narrow_left,
          size: 30,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size(double.infinity, 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayDelivered
                  ? 'Successfully Delivered'
                  : 'Arriving in ${_getETAText()}',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
