import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/my_orders/model/order_detail_model.dart';

class OrderItemsRow extends StatelessWidget {
  final OrderItems item;
  final VoidCallback? onTap;

  const OrderItemsRow({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hasOtp = item.product?.requiresOtp == 1;
    final hasAttachments = item.attachments
        .where((u) => u.trim().isNotEmpty)
        .isNotEmpty;
    final status = getItemStatus(item);
    final hasStatus = status.color != Colors.transparent;
    final mrp = _mrpAmount();
    final subtotalAmount = _subtotalAmount();
    final showStrike = mrp > subtotalAmount && mrp > 0;
    final subline = _buildSubline(l10n);
    final hasComplexSubline =
        item.addons.isNotEmpty || (item.product?.requiresOtp == 1);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: hasStatus ? status.color : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: hasStatus ? 8.w : 0,
          vertical: 9.h,
        ),
        child: Row(
          crossAxisAlignment: hasComplexSubline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.start,
          children: [
            _thumbnail(context),
            SizedBox(width: 10.w),
            Expanded(child: _buildTextColumn(context, l10n, hasOtp, hasAttachments, subline)),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showStrike)
                  Text(
                    '${AppHelpers.currency}${mrp.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                      decoration: TextDecoration.lineThrough,
                      height: 1,
                    ),
                  ),
                Text(
                  '${AppHelpers.currency}${subtotalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(BuildContext context) {
    final imageUrl = item.product?.image ?? '';
    final scheme = Theme.of(context).colorScheme;
    if (imageUrl.trim().isEmpty) {
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          TablerIcons.package,
          size: 18.sp,
          color: scheme.onSurfaceVariant,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 36.w,
        height: 36.w,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: scheme.surfaceContainer,
        ),
        errorWidget: (_, __, ___) => Container(
          width: 36.w,
          height: 36.w,
          color: scheme.surfaceContainer,
          alignment: Alignment.center,
          child: Icon(
            TablerIcons.package,
            size: 18.sp,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTextColumn(
    BuildContext context,
    AppLocalizations? l10n,
    bool hasOtp,
    bool hasAttachments,
    String subline,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final name = item.product?.name ?? item.title ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: SizedBox(
                width: 180.w,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            if (hasAttachments) ...[
              SizedBox(width: 6.w),
              Icon(
                TablerIcons.paperclip,
                size: 12.sp,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
        if (subline.isNotEmpty) ...[
          SizedBox(height: 2.h),
          SizedBox(
            width: 200.w,
            child: Text(
              subline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          if (hasOtp &&
              item.status != 'delivered' &&
              item.status != 'returned' &&
              item.status != 'cancelled' &&
              item.status != 'refunded') ...[
            SizedBox(width: 6.w),
            _Chip(
              label: l10n?.otpChip ?? 'OTP',
              bg: AppTheme.warningColor.withValues(alpha: 0.18),
              fg: AppTheme.warningColor,
            ),
          ],
        ],
      ],
    );
  }

  String _buildSubline(AppLocalizations? l10n) {
    final variant = item.variant?.title ?? item.variantTitle;
    final addons = item.addons
        .map((a) => a.item?.title ?? '')
        .where((t) => t.trim().isNotEmpty)
        .join(', ');
    final qty = item.quantity ?? 1;
    final qtyLabel = l10n?.qtyShort(qty) ?? 'Qty $qty';

    final parts = <String>[];
    if (variant != null && variant.trim().isNotEmpty) parts.add(variant);
    if (addons.isNotEmpty) parts.add(addons);
    parts.add(qtyLabel);
    return parts.join(' · ');
  }

  double _subtotalAmount() {
    final raw = item.subtotal;
    if (raw == null) return 0;
    return double.tryParse(raw) ?? 0;
  }

  double _mrpAmount() {
    final priceRaw = item.price;
    final qty = item.quantity ?? 1;
    if (priceRaw == null) return 0;
    final unit = double.tryParse(priceRaw) ?? 0;
    return unit * qty;
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
