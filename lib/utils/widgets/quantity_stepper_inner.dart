import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../config/helper.dart';
import '../../services/user_cart/cart_validation.dart';
import 'custom_toast.dart';

class QuantityStepperInner extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int currentLocalQty;
  final int stepSize;
  final int minQty;
  final int totalAllowedQuantity;
  final int stock;
  final bool isStoreOpen;
  final Color? color;

  const QuantityStepperInner({
    required Key key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.currentLocalQty,
    required this.stepSize,
    required this.minQty,
    required this.totalAllowedQuantity,
    required this.stock,
    required this.isStoreOpen,
    this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Icon(
            TablerIcons.minus,
            size: 16.r,
            color: color ?? Colors.white,
          ),
        ),
        Text(
          quantity.toString(),
          style: TextStyle(
            fontSize: isTablet(context) ? 18 : 12.sp,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        GestureDetector(
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
              onIncrement();
            }
          },
          child: Icon(
            TablerIcons.plus,
            size: 16.r,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }
}