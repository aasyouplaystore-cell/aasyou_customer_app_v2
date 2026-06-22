// TODO(fulfillment-mode): DO NOT wire this widget into cart_page.dart until the
// following companion patches land in the same merge:
//   1. CartUIState gets `final FulfillmentMode selectedFulfillmentMode` threaded
//      through copyWith + props, plus a SetFulfillmentMode event + handler in
//      CartUIBloc. cart_page.dart must drive this widget from a
//      BlocBuilder<CartUIBloc, CartUIState>, NOT a local setState field —
//      otherwise BillSummaryWidget / DeliveryTypeWidget / DeliveryAddressWidget
//      will read stale fulfillment state.
//   2. CreateOrderRequest (customer-app/lib/screens/my_orders/bloc/create_order/
//      create_order_event.dart) gets a `fulfillmentMode` field, and the repo
//      serialization in order_repo.dart emits it in the HTTP body
//      (e.g. {'fulfillment_mode': 'self_pickup' | 'delivery'}). Without this,
//      the user's self-pickup selection is silently dropped at the network
//      boundary and the backend always treats the order as delivery.
// Until BOTH of the above land, this widget should not be mounted.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/theme.dart';
import '../../../config/helper.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/cart_ui_bloc/cart_ui_state.dart' show FulfillmentMode;

// FulfillmentMode is canonical in cart_ui_state.dart and re-exported above.

class FulfillmentToggleWidget extends StatelessWidget {
  final FulfillmentMode? selectedMode;
  final ValueChanged<FulfillmentMode> onModeChanged;
  final bool isSelfPickupAvailable;
  final String? unavailableReason;

  const FulfillmentToggleWidget({
    super.key,
    this.selectedMode,
    required this.onModeChanged,
    this.isSelfPickupAvailable = true,
    this.unavailableReason,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // If self-pickup is unavailable but currently selected → auto-switch to delivery
    if (!isSelfPickupAvailable && selectedMode == FulfillmentMode.selfPickup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onModeChanged(FulfillmentMode.delivery);
      });
    }

    // Resolve the explanation shown under the disabled self-pickup tile.
    // Prefer the caller-supplied reason; otherwise fall back to a generic l10n
    // string so the user is never left staring at a greyed-out option with no
    // explanation.
    final String? resolvedUnavailableReason = !isSelfPickupAvailable
        ? ((unavailableReason != null && unavailableReason!.isNotEmpty)
            ? unavailableReason
            : (l10n?.fulfillmentSelfPickupUnavailable ??
                'Self pickup is not available right now'))
        : null;

    return Container(
      padding: EdgeInsets.only(
        left: 12.0.w,
        right: 12.0.w,
        top: 12.h,
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.fulfillmentMode ?? 'How would you like to receive?',
            style: TextStyle(
              fontSize: isTablet(context) ? 24 : 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          _buildFulfillmentOption(
            context: context,
            mode: FulfillmentMode.delivery,
            icon: TablerIcons.truck_delivery,
            title: l10n?.fulfillmentDelivery ?? 'Delivery',
            subtitle: l10n?.fulfillmentDeliverySubtitle ??
                'Standard delivery to your address',
            disabledReason: null,
          ),
          SizedBox(height: 8.h),
          _buildFulfillmentOption(
            context: context,
            mode: FulfillmentMode.selfPickup,
            icon: TablerIcons.building_store,
            title: l10n?.fulfillmentSelfPickup ?? 'Self Pickup',
            subtitle: l10n?.fulfillmentSelfPickupSubtitle ??
                'Collect from the store yourself',
            disabledReason: resolvedUnavailableReason,
          ),
        ],
      ),
    );
  }

  Widget _buildFulfillmentOption({
    required BuildContext context,
    required FulfillmentMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
    required String? disabledReason,
  }) {
    final bool isEnabled =
        mode == FulfillmentMode.delivery || isSelfPickupAvailable;
    final bool isSelected = selectedMode == mode;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: InkWell(
        // Match DeliveryTypeWidget's pattern: when disabled, onTap is null so
        // the tile produces no ripple and no silent dead zone. The inline
        // italic `disabledReason` below is the single channel for explaining
        // why the option is unavailable.
        onTap: isEnabled ? () => onModeChanged(mode) : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: isSelected
                ? Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    width: 1.0)
                : Border.all(color: Theme.of(context).colorScheme.outline),
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEnabled)
                RadioGroup<FulfillmentMode>(
                  groupValue: selectedMode,
                  onChanged: (FulfillmentMode? value) {
                    if (value != null) {
                      onModeChanged(value);
                    }
                  },
                  child: Radio<FulfillmentMode>(
                    value: mode,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    activeColor: AppTheme.primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )
              else
                Radio<FulfillmentMode>(
                  value: mode,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              SizedBox(width: 8.w),
              Icon(
                icon,
                size: isTablet(context) ? 24 : 20.sp,
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey[700],
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet(context) ? 18 : 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet(context) ? 14 : 10.sp,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    if (disabledReason != null && disabledReason.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        disabledReason,
                        style: TextStyle(
                          fontSize: isTablet(context) ? 12 : 9.sp,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
