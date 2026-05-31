import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/my_orders/widgets/product_not_found_widget.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import 'package:aasyou/utils/widgets/hero_tags.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/helper.dart';
import '../../product_detail_page/view/product_detail_page.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import '../model/order_detail_model.dart';

({String label, Color bg, Color fg})? _itemPillConfig(
    String? status, bool dark) {
  if (status == null || status.trim().isEmpty) return null;
  switch (status.toLowerCase().trim()) {
    case 'pending':
      return dark
          ? (label: 'Pending', bg: const Color(0xFF0C4A6E), fg: const Color(0xFFBAE6FD))
          : (label: 'Pending', bg: const Color(0xFFE0F2FE), fg: const Color(0xFF075985));
    case 'awaiting_store_response':
      return dark
          ? (label: 'Awaiting Store Response', bg: const Color(0xFF78350F), fg: const Color(0xFFFCD34D))
          : (label: 'Awaiting Store Response', bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E));
    case 'accepted':
      return dark
          ? (label: 'Accepted', bg: const Color(0xFF14532D), fg: const Color(0xFF86EFAC))
          : (label: 'Accepted', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534));
    case 'rejected':
      return dark
          ? (label: 'Rejected', bg: const Color(0xFF881337), fg: const Color(0xFFFDA4AF))
          : (label: 'Rejected', bg: const Color(0xFFFFE4E6), fg: const Color(0xFF9F1239));
    case 'preparing':
      return dark
          ? (label: 'Preparing', bg: const Color(0xFF134E4A), fg: const Color(0xFF99F6E4))
          : (label: 'Preparing', bg: const Color(0xFFCCFBF1), fg: const Color(0xFF0F766E));
    case 'collected':
      return dark
          ? (label: 'Collected', bg: const Color(0xFF1E1B4B), fg: const Color(0xFFA5B4FC))
          : (label: 'Collected', bg: const Color(0xFFE0E7FF), fg: const Color(0xFF4338CA));
    case 'delivered':
      return dark
          ? (label: 'Delivered', bg: const Color(0xFF14532D), fg: const Color(0xFF86EFAC))
          : (label: 'Delivered', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534));
    case 'returned':
      return dark
          ? (label: 'Returned', bg: const Color(0xFF4C1D95), fg: const Color(0xFFC4B5FD))
          : (label: 'Returned', bg: const Color(0xFFEDE9FE), fg: const Color(0xFF5B21B6));
    case 'refunded':
      return dark
          ? (label: 'Refunded', bg: const Color(0xFF4C1D95), fg: const Color(0xFFC4B5FD))
          : (label: 'Refunded', bg: const Color(0xFFEDE9FE), fg: const Color(0xFF5B21B6));
    case 'cancelled':
      return dark
          ? (label: 'Cancelled', bg: const Color(0xFF881337), fg: const Color(0xFFFDA4AF))
          : (label: 'Cancelled', bg: const Color(0xFFFFE4E6), fg: const Color(0xFF9F1239));
    case 'failed':
      return dark
          ? (label: 'Failed', bg: const Color(0xFF881337), fg: const Color(0xFFFDA4AF))
          : (label: 'Failed', bg: const Color(0xFFFFE4E6), fg: const Color(0xFF9F1239));
    default:
      return null;
  }
}

Map<String, List<OrderItems>> groupCartItemsByStore(List<OrderItems> items) {
  Map<String, List<OrderItems>> groupedItems = {};

  for (var item in items) {

    /*if (!_isValidItem(item)) continue;*/

    String storeKey = item.store?.name ?? 'Unknown Store';
    if (!groupedItems.containsKey(storeKey)) {
      groupedItems[storeKey] = [];
    }
    groupedItems[storeKey]!.add(item);
  }
  return groupedItems;
}

bool _isValidProduct(OrderDetailProduct product) {
  if (product.name == null) return false;
  return true;
}

class OrderItemsCard extends StatelessWidget {
  final List<OrderItems> items;
  final String totalItems;
  final VoidCallback? onAddMoreItems;
  final Color? priceColor;
  final Color? originalPriceColor;

  const OrderItemsCard({
    super.key,
    required this.items,
    required this.totalItems,
    this.onAddMoreItems,
    this.priceColor,
    this.originalPriceColor,
  });

  @override
  Widget build(BuildContext context) {
    final groupedItems = groupCartItemsByStore(items);
    return Column(
      children: groupedItems.entries.map((entry) {
        final storeName = entry.key;
        final storeItems = entry.value;

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: StoreCartSection(
            storeName: storeName,
            items: storeItems,
            deliveryTime: totalItems,
            onAddMoreItems: onAddMoreItems,
            priceColor: priceColor,
            originalPriceColor: originalPriceColor,
          ),
        );
      }).toList(),
    );
  }
}

class StoreCartSection extends StatelessWidget {
  final String storeName;
  final List<OrderItems> items;
  final String deliveryTime;
  final VoidCallback? onAddMoreItems;
  final Color? priceColor;
  final Color? originalPriceColor;

  const StoreCartSection({
    super.key,
    required this.storeName,
    required this.items,
    required this.deliveryTime,
    this.onAddMoreItems,
    this.priceColor,
    this.originalPriceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStoreHeader(context),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: _buildCartItem(context, item),
            )),
      ],
    );
  }

  Widget _buildStoreHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                AppHelpers.systemVendorTypeIsSingle
                    ? AppLocalizations.of(context)!.totalItems
                    : storeName,
                style: TextStyle(
                  fontSize: isTablet(context) ? 24 : 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
          Text(
            '${items.length} Product${items.length != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: isTablet(context) ? 18 : 12.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, OrderItems item) {
    final isValidProduct = _isValidProduct(item.product ?? OrderDetailProduct());
    final status = getItemStatus(item);
    return OpenContainer(
        clipBehavior: Clip.antiAlias,
        transitionDuration: const Duration(milliseconds: 500),
        transitionType: ContainerTransitionType.fade,
        closedElevation: 0,
        openElevation: 0,
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        openShape:
            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        closedColor: Colors.transparent,
        openColor: Colors.transparent,
        tappable: isValidProduct,
        useRootNavigator: true,
        openBuilder: (context, closeContainer) {
          if(!isValidProduct) return const SizedBox.shrink();
          return ProductDetailPage(
            productSlug: item.product!.slug!,
            initialData: ProductInitialData(
              title: item.product!.name!,
              mainImage: item.product!.image!,
            ),
            closeContainer: closeContainer,
          );
        },
        closedBuilder: (context, openContainer) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main row with image, info, price
                Opacity(
                  opacity: 1.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      _buildProductImage(
                          item.product?.image! ?? '', item.product?.slug ?? '', isValidProduct),
                      SizedBox(width: 10.w),

                      // Product Name and Details
                      Expanded(child: _buildProductInfo(item, context)),
                      SizedBox(width: 10.w),

                      // Price Section
                      _buildPriceSection(item, context),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                _buildAttachmentsSection(item, context),

                // Status message below (only if applicable)
                if (status.message != null) ...[
                  SizedBox(height: 14.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8.r)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            status.icon,
                            size: 18.sp,
                            color: status.color,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              status.message!,
                              style: TextStyle(
                                color: status.color,
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (!isValidProduct)
                  buildProductNotFoundBanner(context),
              ],
            ),
          );
        });
  }

  Widget _buildProductImage(String? imageUrl, String productSlug, bool isValid) {
    if (!isValid || imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade200,
        ),
        child: Icon(
          TablerIcons.package,
          size: 24.sp,
          color: Colors.grey.shade500,
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Hero(
          tag: productHeroTag(productSlug),
          child: CustomImageContainer(
            imagePath: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(OrderItems item, BuildContext context) {
    // Comma-separated addon names below the variant title — mirrors the
    final String addonsText = item.addons
        .map((a) => a.item?.title ?? '')
        .where((t) => t.isNotEmpty)
        .join(', ');

    return SizedBox(
      width: 125.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.product?.name! ?? item.title!,
            style: TextStyle(
                fontSize: isTablet(context) ? 18 : 12.sp,
                fontWeight: FontWeight.w500,
                fontFamily: AppTheme.fontFamily),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.variant?.title! ?? item.variantTitle!}, $addonsText ',
                  style: TextStyle(
                    fontSize: isTablet(context) ? 16 : 10.sp,
                    color: Colors.grey[500],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
             // if (addonsText.isNotEmpty) ...[
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'Qty: ${item.quantity}',
            style: TextStyle(
              fontSize: isTablet(context) ? 16 : 10.sp,
              color: Colors.grey[500],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          () {
            final pill = _itemPillConfig(
              item.status,
              Theme.of(context).brightness == Brightness.dark,
            );
            if (pill == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: _ItemStatusPill(
                  label: pill.label, bg: pill.bg, fg: pill.fg),
            );
          }(),
          if (item.product?.requiresOtp == 1 &&
              item.otp != null &&
              item.status != 'delivered' &&
              item.status != 'returned' &&
              item.status != 'cancelled' &&
              item.status != 'refunded') ...[
            SizedBox(height: 6.h),
            _OtpBadge(otp: item.otp.toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSection(OrderItems item, BuildContext context) {
   // String itemTotal = '${AppHelpers.currency}${(
    String itemTotal= '${AppHelpers.currency}${item.subtotal}';

    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            itemTotal,
            style: TextStyle(
              fontSize: isTablet(context) ? 18 : 12.sp,
              fontWeight: FontWeight.w600,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(OrderItems item, BuildContext context) {
    // Safety check: no attachments or empty
    if (item.attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Flatten all URLs from nested list
    final allUrls = item.attachments
        .where((url) => url.isNotEmpty && url.trim().isNotEmpty)
        .toList();

    if (allUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDarkMode(context)
            ? Colors.grey.shade800.withValues(alpha: 0.4)
            : Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heade
          Row(
            children: [
              Icon(
                TablerIcons.paperclip,
                size: 16.sp,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: 6.w),
              Text(
                'Attachments (${allUrls.length})',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode(context) ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // List of attachments
          ...allUrls.map((url) {
            final isImage = _isImageUrl(url);
            final fileName = _getFileNameFromUrl(url);

            return GestureDetector(
              onTap: () => _openAttachment(url, context),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Preview / Icon
                    if (isImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: Image.network(
                          url,
                          width: 50.w,
                          height: 50.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFileIcon(url),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 50.w,
                              height: 50.w,
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            );
                          },
                        ),
                      )
                    else
                      _buildFileIcon(url),

                    SizedBox(width: 12.w),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            isImage ? 'Image' : _getFileTypeFromUrl(url),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Open icon
                    Icon(
                      TablerIcons.external_link,
                      size: 18.sp,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Helper Functions ─────────────────────────────────────────────────────────

  Widget _buildFileIcon(String url) {
    final ext = _getExtension(url).toLowerCase();

    IconData icon;
    Color color;

    if (ext.contains('pdf')) {
      icon = TablerIcons.file_type_pdf;
      color = Colors.red;
    } else if (['doc', 'docx'].contains(ext)) {
      icon = TablerIcons.file_type_docx;
      color = Colors.blue;
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      icon = TablerIcons.photo;
      color = Colors.green;
    } else {
      icon = TablerIcons.file;
      color = Colors.grey;
    }

    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: 28.sp),
    );
  }

  bool _isImageUrl(String url) {
    final ext = _getExtension(url).toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  String _getExtension(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    final path = uri.path;
    final dotIndex = path.lastIndexOf('.');
    return dotIndex != -1 ? path.substring(dotIndex + 1) : '';
  }

  String _getFileNameFromUrl(String url) {
    try{
      final uri = Uri.tryParse(url);
      if (uri == null) return 'Attachment';
      final path = uri.pathSegments.last;
      log('File Name Path $path');
      return Uri.decodeComponent(path);
    } catch(e, err) {
      log('File Name From URL  ${err.toString()}');
      return 'Image-1';
    }
  }

  String _getFileTypeFromUrl(String url) {
    final ext = _getExtension(url).toUpperCase();
    if (ext.isEmpty) return 'File';
    return ext;
  }

  Future<void> _openAttachment(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);

      // If it's a remote URL, try to open in browser/external app
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.cannotOpenFile(url))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorOpeningAttachment(e.toString()))),
        );
      }
    }
  }
}

class _OtpBadge extends StatelessWidget {
  final String otp;
  const _OtpBadge({required this.otp});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: dark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 11.sp,
            color: dark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
          ),
          SizedBox(width: 4.w),
          Text(
            'OTP: ',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: dark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
            ),
          ),
          Text(
            otp,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: dark ? const Color(0xFFE0E7FF) : const Color(0xFF312E81),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemStatusPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _ItemStatusPill({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
