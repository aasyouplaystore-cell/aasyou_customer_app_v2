import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/user_cart/cart_validation.dart';
import 'custom_toast.dart';

class AddButtonInner extends StatelessWidget {
  final VoidCallback? onTap;
  final double opacity;
  final int currentLocalQty;
  final int stepSize;
  final int minQty;
  final int totalAllowedQuantity;
  final int stock;
  final bool isStoreOpen;

  const AddButtonInner({
    required Key key,
    required this.onTap,
    required this.opacity,
    required this.currentLocalQty,
    required this.stepSize,
    required this.minQty,
    required this.totalAllowedQuantity,
    required this.stock,
    required this.isStoreOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: () {
          final error = CartValidation.validateProductAddToCart(
            context: context,
            requestedQuantity: currentLocalQty + stepSize,
            minQty: minQty,
            maxQty: totalAllowedQuantity,
            stock: stock,
            isStoreOpen: isStoreOpen,
          );
          if (error != null) {
            ToastManager.show(
                context: context, message: error, type: ToastType.error);
            return;
          } else {
            onTap!();
          }
        },
        child: Text(
          AppLocalizations.of(context)?.add ?? 'Add',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}