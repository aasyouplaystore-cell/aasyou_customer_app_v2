import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/delivery_zone_list/model/delivery_zone_model.dart';
import '../../../config/helper.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';

class DeliveryZoneCard extends StatelessWidget {
  final DeliveryZoneData zone;

  const DeliveryZoneCard({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: (){
          GoRouter.of(context).push(
            AppRoutes.deliveryZoneDetail,
            extra: {
              'zoneId': zone.id
            }
          );
        },
        child: Container(
          // elevation: isDark ? 4 : 2,
          decoration: BoxDecoration(
            color: isDarkMode(context) ? Theme.of(context).colorScheme.onSecondary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(TablerIcons.map_pin_filled, color: AppTheme.primaryColor, size: 20),
                              ),
                              const SizedBox(width: 5,),
                              Text(
                                zone.name!,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatusBadge(context, zone.status!),
                              if (zone.rushDeliveryEnabled!) ...[
                                const SizedBox(width: 8),
                                _buildRushBadge(context),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Info Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context: context,
                        icon: TablerIcons.truck_delivery,
                        label: l10n?.deliveryFee ?? "Delivery Fee",
                        value: zone.regularDeliveryCharges != null ? "${AppHelpers.currency}${zone.regularDeliveryCharges}" : 'N/A',
                        accentColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        context: context,
                        icon: Icons.card_giftcard_rounded,
                        label: l10n?.freeDeliveryAbove ?? "Free Delivery Above",
                        value:  zone.freeDeliveryAmount != null ? "${AppHelpers.currency}${zone.freeDeliveryAmount}" : 'N/A',
                        accentColor: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Radius info
                _buildRadiusCard(context),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.successColor
                  : theme.colorScheme.onSecondaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            capitalizeFirstLetter(status),
            style: TextStyle(
              color: isActive
                  ? (isDark ? AppTheme.successColor : AppTheme.successColor.withValues(alpha: 0.9))
                  : theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            l10n?.rush ?? "Rush",
            style: TextStyle(
              color: isDark
                  ? AppTheme.warningColor
                  : AppTheme.warningColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 20,
            ),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

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
            child: const Icon(
              Icons.location_on_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n?.coverageRadius ?? "Coverage Radius",
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            "${zone.radiusKm} km",
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
}