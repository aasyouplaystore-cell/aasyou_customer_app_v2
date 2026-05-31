import 'package:flutter/material.dart';
import 'package:aasyou/l10n/app_localizations.dart';

class OrderDetailsSection extends StatelessWidget {
  final String orderId;
  final String payment;
  final String orderPlaced;
  final String placedAt;

  const OrderDetailsSection({
    super.key,
    required this.orderId,
    required this.payment,
    required this.orderPlaced,
    required this.placedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.orderDetails,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Column(
              children: [
                _buildOrderDetailRow(
                    AppLocalizations.of(context)!.orderId, orderId),
                _buildOrderDetailRow(
                    AppLocalizations.of(context)!.payment, payment),
                _buildOrderDetailRow(
                    AppLocalizations.of(context)!.orderPlaced, placedAt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
