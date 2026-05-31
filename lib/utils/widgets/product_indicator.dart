import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget productIndicator (String indicator) {
  return indicator.isNotEmpty ? Container(
    width: 14.sp,
    height: 14.sp,
    padding: EdgeInsets.all(2.sp),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: indicator == 'veg' ? Colors.green : Colors.red,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: indicator == 'veg' ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    ),
  ) : const SizedBox.shrink();
}