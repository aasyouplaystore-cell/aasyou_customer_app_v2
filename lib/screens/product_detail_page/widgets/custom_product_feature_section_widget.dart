//




import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';

class CustomProductFeatureSectionWidget extends StatelessWidget {
  final List<CustomProductFeaturedSections> sections;

  const CustomProductFeatureSectionWidget({
    super.key,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
      log('BIBGRG');
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;

        final fields = section.fields ?? [];

        if (fields.isEmpty) return const SizedBox.shrink();

        final bool isLast = index == sections.length - 1;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.r),
          ),
          margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: isLast ? 0.h : 32.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title (e.g. "Say Yes to fresh!", "Why Choose Us", etc.)
                if (section.title?.isNotEmpty == true)
                  Text(
                    section.title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                // Optional section description/subtitle
                if (section.description?.isNotEmpty == true) ...[
                  SizedBox(height: 4.h),
                  Text(
                    section.description!,
                    style: TextStyle(
                      fontSize: 14  ,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                  ),
                ],

                SizedBox(height: section.title != null || section.description != null ? 20.h : 0.h),

                // All feature items (fields) of this section
                ...fields.map((field) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: _buildFeatureItem(
                      image: field.image ?? '',
                      icon: _mapIcon(field.title ?? ''),
                      color: _mapColor(field.title ?? ''),
                      title: field.title ?? 'Feature',
                      description: field.description ?? '',
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String image,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Container(
            width: 55.w,
            height: 55.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: CustomImageContainer(
              imagePath: image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description.trim().isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Simple heuristic-based icon & color mapping
  IconData _mapIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('fresh') || t.contains('sourced') || t.contains('daily')) {
      return Icons.eco_outlined;
    }
    if (t.contains('expert') || t.contains('team')) {
      return Icons.people_alt_outlined;
    }
    if (t.contains('quality') || t.contains('check') || t.contains('audit')) {
      return Icons.verified_outlined;
    }
    if (t.contains('pack') || t.contains('hygiene')) {
      return Icons.inventory_2_outlined;
    }
    if (t.contains('store') || t.contains('assurance') || t.contains('shop')) {
      return Icons.storefront_outlined;
    }
    return Icons.check_circle_outline_rounded;
  }

  Color _mapColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('fresh') || t.contains('sourced')) return Colors.green.shade600;
    if (t.contains('expert')) return Colors.teal.shade600;
    if (t.contains('quality') || t.contains('check')) return Colors.blue.shade600;
    if (t.contains('pack') || t.contains('hygiene')) return Colors.green.shade700;
    if (t.contains('store') || t.contains('assurance')) return Colors.orange.shade700;
    return AppTheme.primaryColor;
  }
}