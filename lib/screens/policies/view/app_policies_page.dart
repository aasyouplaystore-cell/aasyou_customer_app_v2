import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';

import '../../../config/settings_data_instance.dart';
import '../../../config/theme.dart';

/// Enum that represents every policy you need.
enum PolicyType {
  aboutUs,
  privacyPolicy,
  termsAndConditions,
  refundPolicy,
  shippingPolicy,
  // add more here if needed
}

/// Extension to get a human-readable title for the AppBar.
extension PolicyTitle on PolicyType {
  String get title {
    switch (this) {
      case PolicyType.aboutUs:
        return 'About Us';
      case PolicyType.privacyPolicy:
        return 'Privacy Policy';
      case PolicyType.termsAndConditions:
        return 'Terms & Conditions';
      case PolicyType.refundPolicy:
        return 'Refund Policy';
      case PolicyType.shippingPolicy:
        return 'Shipping Policy';
    }
  }

  /// Returns the HTML string from SettingsData (or an empty string if missing).
  String get htmlContent {
    final web = SettingsData.instance.web;
    switch (this) {
      case PolicyType.aboutUs:
        return web?.aboutUs ?? '';
      case PolicyType.privacyPolicy:
        return web?.privacyPolicy ?? '';
      case PolicyType.termsAndConditions:
        return web?.termsCondition ?? '';
      case PolicyType.refundPolicy:
        return web?.returnRefundPolicy ?? '';
      case PolicyType.shippingPolicy:
        return web?.shippingPolicy ?? '';
    }
  }
}

/// Reusable policy page.
class PolicyPage extends StatelessWidget {
  final PolicyType policyType;

  const PolicyPage({super.key, required this.policyType});

  @override
  Widget build(BuildContext context) {
    final String html = policyType.htmlContent;
    final String title = policyType.title;
    final bool isEmpty = html.trim().isEmpty;

    return CustomScaffold(
      showViewCart: false,
      showAppBar: true,
      title: title,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: isEmpty
            ? const _PolicyEmptyState()
            : SingleChildScrollView(
                child: Html(
                  shrinkWrap: true,
                  data: html,
                ),
              ),
      ),
    );
  }
}

/// Friendly placeholder shown when the policy HTML coming from
/// `/api/settings` is missing or empty. Uses only existing brand tokens
/// (no new dependencies, no palette changes).
class _PolicyEmptyState extends StatelessWidget {
  const _PolicyEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: const BoxDecoration(
                color: AppTheme.brandPrimarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 48.w,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Content coming soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "We're updating this page. Please check back later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}