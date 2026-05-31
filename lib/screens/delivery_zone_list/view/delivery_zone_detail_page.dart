import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/delivery_zone_list/model/delivery_zone_detail_model.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import '../../../config/helper.dart';
import '../../../config/theme.dart';
import '../bloc/delivery_zone_detail/delivery_zone_detail_bloc.dart';
import '../widgets/map_section_delivery_zone.dart';

class DeliveryZoneDetailPage extends StatefulWidget {
  final int zoneId;
  const DeliveryZoneDetailPage({super.key, required this.zoneId});

  @override
  State<DeliveryZoneDetailPage> createState() => _DeliveryZoneDetailPageState();
}

class _DeliveryZoneDetailPageState extends State<DeliveryZoneDetailPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    context.read<DeliveryZoneDetailBloc>().add(FetchDeliveryZoneDetail(zoneId: widget.zoneId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.tertiary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n?.zoneDetails ?? 'Zone Details',
          style: TextStyle(
            color: theme.colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<DeliveryZoneDetailBloc, DeliveryZoneDetailState>(
        builder: (BuildContext context, DeliveryZoneDetailState state) {
          if(state is DeliveryZoneDetailLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zone Header
                  _buildHeader(
                    context: context,
                    zone: state.deliveryZoneDetail
                  ),

                  const SizedBox(height: 16),

                  // Map Section
                  buildMapSection(
                      context: context,
                      zone: state.deliveryZoneDetail
                  ),

                  const SizedBox(height: 16),

                  // Zone Information
                  _buildZoneInformation(
                    context: context,
                    zone: state.deliveryZoneDetail
                  ),

                  const SizedBox(height: 16),

                  // Delivery Fees Section
                  _buildDeliveryFeesSection(
                    context: context,
                    zone: state.deliveryZoneDetail
                  ),

                  const SizedBox(height: 16),

                  // Delivery Times Section
                  _buildDeliveryTimesSection(
                    context: context,
                    zone: state.deliveryZoneDetail
                  ),

                  const SizedBox(height: 16),

                  // Coverage Details Section
                  _buildCoverageDetailsSection(
                    context: context,
                    zone: state.deliveryZoneDetail
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          } else if (state is DeliveryZoneDetailLoading) {
            return const CustomCircularProgressIndicator();
          } else if (state is DeliveryZoneDetailFailed) {
            return Container();
          }
          return const CustomCircularProgressIndicator();
        },
      ),
    );
  }

  Widget _buildHeader({required BuildContext context, required DeliveryZoneDetailData zone}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            zone.name ?? '',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.viewDetailsAboutDeliveryZone ?? 'View details about delivery zone',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusBadge(context, capitalizeFirstLetter(zone.status ?? 'Active')),
              if (zone.rushDeliveryEnabled ?? false) ...[
                const SizedBox(width: 8),
                _buildRushBadge(context),
              ],
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildZoneInformation({required BuildContext context, required DeliveryZoneDetailData zone}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.zoneInformation ?? 'Zone Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoTile(
                context,
                icon: Icons.tag,
                label: l10n?.zoneId ?? 'Zone ID',
                value: zone.id?.toString() ?? 'N/A',
              ),
              _buildDivider(context),
              _buildInfoTile(
                context,
                icon: Icons.location_city,
                label: l10n?.zoneName ?? 'Zone Name',
                value: zone.name ?? 'N/A',
              ),
              _buildDivider(context),
              _buildInfoTile(
                context,
                icon: Icons.circle,
                label: l10n?.status ?? 'Status',
                value: capitalizeFirstLetter(zone.status ?? 'N/A'),
                valueColor: zone.status?.toLowerCase() == 'active'
                    ? AppTheme.successColor
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryFeesSection({required BuildContext context, required DeliveryZoneDetailData zone}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                      AppHelpers.currency,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 20,
                    )
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.deliveryFees ?? 'Delivery Fees',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFeeCard(
                      context,
                      icon: TablerIcons.truck_delivery,
                      label: l10n?.regularDelivery ?? 'Regular Delivery',
                      value: '${AppHelpers.currency}${zone.regularDeliveryCharges ?? 0}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFeeCard(
                      context,
                      icon: Icons.card_giftcard,
                      label: l10n?.freeDeliveryAbove ?? 'Free Delivery Above',
                      value: '${AppHelpers.currency}${zone.freeDeliveryAmount ?? 0}',
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFeeCard(
                      context,
                      icon: Icons.route,
                      label: l10n?.perKMCharge ?? 'Per KM Charge',
                      value: '${AppHelpers.currency}${zone.distanceBasedDeliveryCharges ?? 0}/km',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFeeCard(
                      context,
                      icon: Icons.store,
                      label: l10n?.perStoreFee ?? 'Per Store Fee',
                      value: '${AppHelpers.currency}${zone.perStoreDropOffFee ?? 0}',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFeeCard(
                context,
                icon: Icons.add_outlined,
                label: l10n?.handlingFee ?? 'Handling Fee',
                value: '${AppHelpers.currency}${zone.handlingCharges ?? 0}',
                color: Colors.teal,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryTimesSection({required BuildContext context, required DeliveryZoneDetailData zone}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.deliveryTimes ?? 'Delivery Times',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTimeCard(
                context,
                icon: Icons.schedule,
                label: l10n?.regularTimePerKM ?? 'Regular Time Per KM',
                value: '${zone.deliveryTimePerKm ?? 0} min',
              ),
              const SizedBox(height: 12),
              _buildTimeCard(
                context,
                icon: Icons.timer_outlined,
                label: l10n?.bufferTime ?? 'Buffer Time',
                value: '${zone.bufferTime ?? 0} min',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverageDetailsSection({required BuildContext context, required DeliveryZoneDetailData zone}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.coverageDetails ?? 'Coverage Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoTile(
                context,
                icon: Icons.radio_button_unchecked,
                label: l10n?.radius ?? 'Radius',
                value: '${zone.radiusKm ?? 0} km',
              ),
              _buildDivider(context),
              _buildInfoTile(
                context,
                icon: Icons.location_pin,
                label: l10n?.centerCoordinates ?? 'Center Coordinates',
                value: zone.centerLatitude ?? 'N/A',
                isCoordinate: true,
              ),
              _buildDivider(context),
              if(zone.boundaryJson != null)
                _buildInfoTile(
                  context,
                  icon: Icons.polymer_outlined,
                  label: l10n?.boundaryPoints ?? 'Boundary Points',
                  value: '${zone.boundaryJson!.first.lat ?? 0} points',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = status.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark
            ? AppTheme.successColor.withValues(alpha: 0.2)
            : AppTheme.successColor.withValues(alpha: 0.1))
            : theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppTheme.successColor.withValues(alpha: 0.5)
              : theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.successColor
                  : theme.colorScheme.onSecondaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: isActive
                  ? (isDark ? AppTheme.successColor : AppTheme.successColor.withValues(alpha: 0.8))
                  : theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRushBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.warningColor.withValues(alpha: 0.2)
            : AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            color: AppTheme.warningColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            l10n?.rushDelivery ?? 'Rush Available',
            style: TextStyle(
              color: isDark
                  ? AppTheme.warningColor
                  : AppTheme.warningColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
        bool isFullWidth = false,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: isFullWidth
          ? Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSecondaryContainer,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.tertiary,
            ),
          ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSecondaryContainer,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        Color? valueColor,
        bool isCoordinate = false,
      }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.onSecondaryContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSecondaryContainer,
                fontSize: 14,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isCoordinate ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.colorScheme.tertiary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      color: theme.colorScheme.outline,
      height: 1,
    );
  }
}
