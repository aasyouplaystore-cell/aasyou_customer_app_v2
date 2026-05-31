import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/notification_page/model/notification_list_model.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/screens/product_listing_page/model/product_listing_type.dart';
import '../../../../router/app_routes.dart';
import '../../bloc/notification_bloc.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRead = notification.isRead ?? true;
    final type = notification.type ?? '';
    final metadata = notification.metadata;
    final subtitle = _getSubtitle(metadata, type);

    return InkWell(
      onTap: () => _handleTap(context, notification.type ?? 'general', metadata),
      child: Container(
        // color: isRead ? theme.cardColor : colorScheme.primary.withOpacity(0.06),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),

        ),
        margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 12.w),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!isRead)
                    Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: _iconBgColor(notification.type ?? 'general'),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _iconForType(notification.type ?? 'general'),
                        color: _iconColor(notification.type ?? 'general', colorScheme),
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? 'Notification',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.message ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.5.sp,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5.sp,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Text(
                      _formatRelativeTime(notification.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11.sp,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'new_order':
        return Icons.shopping_bag_outlined;
      case 'order_update':
        return Icons.shopping_bag_outlined;
      case 'return_order_update':
        return Icons.assignment_return_outlined;
      case 'offer':
        return Icons.local_offer_outlined;
      case 'wallet_transaction':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconBgColor(String type) {
    switch (type) {
      case 'new_order':
      case 'order_update':
        return const Color(0xFFE8F0FE);
      case 'return_order':
      case 'return_order_update':
        return const Color(0xFFFFF8E1);
      case 'offer':
      case 'promotion':
        return const Color(0xFFF3E8FD);
      case 'wallet_transaction':
      case 'wallet':
      case 'settlement_process':
      case 'settlement_create':
      case 'withdrawal_request':
        return const Color(0xFFE0F7FA);
      default:
        return AppTheme.primaryColor.withValues(alpha: 0.08);
    }
  }

  Color _iconColor(String type, ColorScheme colorScheme) {
    switch (type) {
      case 'new_order':
        return const Color(0xFF0D47A1);
      case 'order_update':
        return const Color(0xFF1B5E20);
      case 'return_order':
      case 'return_order_update':
        return const Color(0xFFE65100);
      case 'offer':
      case 'promotion':
        return const Color(0xFF6A1B9A);
      case 'wallet_transaction':
      case 'wallet':
        return const Color(0xFF004D40);
      default:
        return colorScheme.primary;
    }
  }

  String? _getSubtitle(Map<String, dynamic>? meta, String type) {
    if (meta == null) return null;
    if (type.contains('OrderItemReturnUpdated')) {
      return 'Item #${meta['order_item_id']} • Status: ${meta['return_status']}';
    } else if (type.contains('SellerSettlementSettled')) {
      return 'Reference: ${meta['settlement_reference']} • Settled at: ${meta['settled_at']}';
    } else if (type.contains('WalletTransactionOccurred')) {
      return 'Transaction #${meta['wallet_transaction_id']} • Type: ${meta['transaction_type']} • Status: ${meta['status']}';
    } else if (type.contains('SellerSettlementCreated')) {
      return 'Statement #${meta['seller_statement_id']} • Type: ${meta['entry_type']}';
    } else if (type.contains('SellerWithdrawalStatusUpdated')) {
      return 'Request #${meta['withdrawal_request_id']} • Status: ${meta['new_status']}';
    }
    return null;
  }

  void _handleTap(BuildContext context, String simplifiedType, Map<String, dynamic>? metadata) {
    if (metadata == null) return;
    String? route;
    Map<String, dynamic> extra = {};
    switch (simplifiedType) {
      case 'order':
        route = AppRoutes.deliveryTracking;
        extra['order-slug'] = metadata['order_slug'];
        break;
      case 'new_order':
        route = AppRoutes.deliveryTracking;
        extra['order-slug'] = metadata['order_slug'];
        break;
      case 'delivery':
        route = AppRoutes.deliveryTracking;
        extra['order-slug'] = metadata['order_slug'];
        break;
      case 'order_update':
        route = AppRoutes.deliveryTracking;
        extra['order-slug'] = metadata['order_slug'];
        break;
      case 'Delivered':
        route = AppRoutes.orderDetail;
        extra['order-slug'] = metadata['order_slug'];
        break;
      case 'return_order':
        route = AppRoutes.orderDetail;
        extra['order-slug'] = metadata['order_slug'];
        break;
      case 'return_order_update':
        route = AppRoutes.orderDetail;
        extra['order-slug'] = metadata['order_slug'];
        break;
      case 'wallet_transaction':
        route = AppRoutes.transactions;
        break;
      case 'product':
          route = AppRoutes.productDetailPage;
          extra['productSlug'] = metadata['slug'];
        break;
      case 'featured_section':
        route = AppRoutes.productListing;
        extra['isTheirMoreCategory'] = false;
        extra['title'] = metadata['title'];
        extra['logo'] = metadata['image'];
        extra['totalProduct'] = 10;
        extra['type'] = ProductListingType.featuredSection;
        extra['identifier'] = metadata['slug'];

        break;
      case 'category':
        route = AppRoutes.productListing;
        extra['isTheirMoreCategory'] = false;
        extra['title'] = metadata['title'];
        extra['logo'] = metadata['image'];
        extra['totalProduct'] = 10;
        extra['type'] = ProductListingType.category;
        extra['identifier'] = metadata['slug'];
        break;
      case 'brand':
        route = AppRoutes.productListing;
        extra['isTheirMoreCategory'] = false;
        extra['title'] = metadata['title'];
        extra['logo'] = metadata['image'];
        extra['totalProduct'] = 10;
        extra['type'] = ProductListingType.brand;
        extra['identifier'] = metadata['slug'];
        break;
      case 'store':
        route = AppRoutes.nearbyStoreDetails;
        extra['store-slug'] = metadata['slug'];
        extra['store-name'] = metadata['title'];
        break;
      default:
        return;
    }

    if (route.isNotEmpty) {
      GoRouter.of(context).push(route, extra: extra);
    }
    context.read<NotificationBloc>().add(MarkAsReadSpecificNotification(notificationId: notification.id.toString()));
    // Optionally mark as read: context.read<NotificationBloc>().add(MarkAsRead(notification.id));
  }

  String _formatRelativeTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays > 1) return '${diff.inDays} days ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inHours > 0) return '${diff.inHours} hours ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
      return 'Just now';
    } catch (_) {
      return isoDate;
    }
  }
}