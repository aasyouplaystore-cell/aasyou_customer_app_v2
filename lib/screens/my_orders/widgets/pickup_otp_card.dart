// FILE: customer-app/lib/screens/my_orders/widgets/pickup_otp_card.dart
//
// 2026-06-20 — Patch 5/9 (self-pickup OTP).
//
// Rendered on the customer order detail screen ONLY when:
//   order.status       == 'ready_for_customer_pickup'
//   order.deliveryMode == 'self_pickup'
//
// Architecture (matches host convention — see delivery_tracking_bloc.dart):
//   * This widget is a StatelessWidget.
//   * Data fetch + state machine live in PickupOtpBloc (companion patch).
//   * The bloc is provided at order_detail_page.dart and dispatches
//     FetchPickupOtp(orderSlug) on mount (companion patch).
//
// User-visible strings are read from AppLocalizations. ARB keys
// (pickupOtpTitle, pickupOtpCopy, pickupOtpCopied, pickupAddressCopied,
//  pickupOtpLoading, pickupOtpFetchFailed, pickupCallStore, pickupOpenMaps,
//  pickupCallFailed, pickupMapsFailed) are added in the companion ARB
// patch — the null-coalesce English defaults below are defensive only.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/my_orders/bloc/pickup_otp/pickup_otp_bloc.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';

// PickupOtpData is canonical in pickup_otp_bloc.dart (imported above).
// The previous duplicate class + toDouble/toStr helpers were removed to
// resolve the ambiguous-import diagnostic.

class PickupOtpCard extends StatelessWidget {
  final String orderSlug;

  const PickupOtpCard({
    super.key,
    required this.orderSlug,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.18),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: BlocBuilder<PickupOtpBloc, PickupOtpState>(
        builder: (context, state) {
          if (state is PickupOtpLoading || state is PickupOtpInitial) {
            return _LoadingView(l10n: l10n);
          }
          if (state is PickupOtpFailed) {
            return _ErrorView(
              l10n: l10n,
              onRetry: () => context
                  .read<PickupOtpBloc>()
                  .add(FetchPickupOtp(orderSlug: orderSlug)),
            );
          }
          if (state is PickupOtpLoaded) {
            return _LoadedView(l10n: l10n, data: state.data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final AppLocalizations? l10n;

  const _LoadingView({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 18.sp,
          width: 18.sp,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          l10n?.pickupOtpLoading ?? 'Fetching pickup OTP…',
          style: TextStyle(fontSize: 12.sp),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final AppLocalizations? l10n;
  final VoidCallback onRetry;

  const _ErrorView({required this.l10n, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.pickupOtpFetchFailed ?? "Couldn't fetch pickup OTP",
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRetry,
            icon: Icon(TablerIcons.refresh, size: 14.sp),
            label: Text(
              l10n?.retry ?? 'Retry',
              style: TextStyle(fontSize: 12.sp),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadedView extends StatelessWidget {
  final AppLocalizations? l10n;
  final PickupOtpData data;

  const _LoadedView({required this.l10n, required this.data});

  Future<void> _copyOtp(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: data.otp));
    if (!context.mounted) return;
    ToastManager.show(
      context: context,
      message: l10n?.pickupOtpCopied ?? 'OTP copied',
    );
  }

  Future<void> _copyAddress(BuildContext context, String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (!context.mounted) return;
    ToastManager.show(
      context: context,
      message: l10n?.pickupAddressCopied ?? 'Address copied',
    );
  }

  Future<void> _callStore(BuildContext context, String phone) async {
    // RFC 3966: `+` is allowed in the path of a tel: URI; strip whitespace.
    final sanitized = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(scheme: 'tel', path: sanitized);
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri);
      return;
    }
    if (!context.mounted) return;
    ToastManager.show(
      context: context,
      message: l10n?.pickupCallFailed ?? "Couldn't open dialer",
      type: ToastType.error,
    );
  }

  Future<void> _openMaps(BuildContext context, double lat, double lng) async {
    final uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    ToastManager.show(
      context: context,
      message: l10n?.pickupMapsFailed ?? "Couldn't open maps",
      type: ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCoords = data.storeLatitude != null && data.storeLongitude != null;
    final hasPhone = data.storePhone != null && data.storePhone!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Icon(
              TablerIcons.qrcode,
              size: 16.sp,
              color: AppTheme.primaryColor,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                l10n?.pickupOtpTitle ?? 'Show this code at the counter',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Big OTP display
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              data.otp.isEmpty ? '----' : data.otp,
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 8.w,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // Copy OTP button
        Center(
          child: TextButton.icon(
            onPressed: data.otp.isEmpty ? null : () => _copyOtp(context),
            icon: Icon(TablerIcons.copy, size: 14.sp),
            label: Text(
              l10n?.pickupOtpCopy ?? 'Copy OTP',
              style: TextStyle(fontSize: 12.sp),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ),

        // Store name
        if (data.storeName != null) ...[
          SizedBox(height: 4.h),
          Divider(height: 16.h, thickness: 1, color: theme.dividerColor),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                TablerIcons.building_store,
                size: 16.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  data.storeName!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],

        // Store address (tap to copy)
        if (data.storeAddress != null) ...[
          SizedBox(height: 8.h),
          InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () => _copyAddress(context, data.storeAddress!),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    TablerIcons.map_pin,
                    size: 16.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      data.storeAddress!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    TablerIcons.copy,
                    size: 14.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Call / Maps row
        if (hasPhone || hasCoords) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              if (hasPhone)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callStore(context, data.storePhone!),
                    icon: Icon(TablerIcons.phone, size: 14.sp),
                    label: Text(
                      l10n?.pickupCallStore ?? 'Call store',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              if (hasPhone && hasCoords) SizedBox(width: 8.w),
              if (hasCoords)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openMaps(
                      context,
                      data.storeLatitude!,
                      data.storeLongitude!,
                    ),
                    icon: Icon(TablerIcons.map_2, size: 14.sp),
                    label: Text(
                      l10n?.pickupOpenMaps ?? 'Directions',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],

        // Pickup instructions
        if (data.pickupInstructions != null) ...[
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  TablerIcons.info_circle,
                  size: 14.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    data.pickupInstructions!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
