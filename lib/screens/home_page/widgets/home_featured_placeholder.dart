import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/utils/widgets/custom_shimmer.dart';

class HomeFeaturedPlaceholder extends StatelessWidget {
  const HomeFeaturedPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isTablet(context) ? 240.h : 350.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: ShimmerWidget.rectangular(
              isBorder: true,
              height: 18,
              width: 200,
              borderRadius: 15,
            ),
          ),
          SizedBox(
            height: 210.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 20),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    children: [
                      ShimmerWidget.rectangular(
                        isBorder: true,
                        height: 105,
                        width: 100,
                        borderRadius: 15,
                      ),
                      const SizedBox(height: 10),
                      ShimmerWidget.rectangular(
                        isBorder: true,
                        height: 15,
                        width: 100,
                        borderRadius: 15,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
