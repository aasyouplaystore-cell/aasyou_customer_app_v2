//




import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';

import '../model/delivery_tracking_model.dart';

class OrderSummaryWidget extends StatelessWidget {
  final TrackedOrder orderData;
  const OrderSummaryWidget({
    super.key,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    // Decide how many images to show fully (adjust as needed)
    const maxVisibleImages = 4;
    final products = orderData.items;
    final totalItems = products.length;
    final showMoreCard = totalItems > maxVisibleImages;
    final visibleCount = showMoreCard ? maxVisibleImages - 1 : totalItems;

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[200],
                    child: Icon(TablerIcons.shopping_bag, size: 30, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.orderSummary,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Order ID: ${orderData.id}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Product images row
            if (totalItems > 0) ...[
              SizedBox(
                height: 75,
                child: Padding(
                  padding: const EdgeInsetsGeometry.directional(start: 12),
                  child: Row(
                    children: [
                      // Visible product images
                      for (int i = 0; i < visibleCount; i++) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildProductImage(products[i].product?.image, context),
                        ),
                      ],

                      // +N more card
                      if (showMoreCard)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildMoreCard(context, totalItems - visibleCount),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // View order details button
            InkWell(
              onTap: (){
                GoRouter.of(context).push(
                  AppRoutes.orderDetail,
                  extra: {
                    'order-slug': orderData.slug
                  }
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant
                    )
                  )
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.viewOrderDetails,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl, BuildContext context) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    return Container(
      width: 75,
      height: 75,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomImageContainer(
        imagePath: imageUrl,
        borderRadius: BorderRadius.circular(12),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildMoreCard(BuildContext context, int remaining) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '+$remaining',
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}