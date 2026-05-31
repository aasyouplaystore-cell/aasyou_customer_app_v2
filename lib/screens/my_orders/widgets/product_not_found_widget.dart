import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildProductNotFoundBanner(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(top: 12.h, left: 8.w, right: 8.w),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18.sp, color: Colors.orange),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'This product is no longer available or has been removed.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}