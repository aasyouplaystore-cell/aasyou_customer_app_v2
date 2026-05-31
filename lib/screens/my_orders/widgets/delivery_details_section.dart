import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/screens/my_orders/model/delivery_tracking_model.dart';
import 'package:remixicon/remixicon.dart';
import 'animated_pulsing_line.dart';
import 'pulsing_icon.dart';

class DeliveryDetailsSection extends StatelessWidget {
  final List<RouteDetail> stops;
  final String destTitle;
  final String destSubtitle;
  final bool isDelivered;

  const DeliveryDetailsSection({
    super.key,
    required this.stops,
    required this.destTitle,
    required this.destSubtitle,
    required this.isDelivered,
  });

  @override
  Widget build(BuildContext context) {
    final activeStep = stops.length - 1;

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: stops.asMap().entries.map((entry) {
              final index = entry.key;
              final stop = entry.value;
              final isLast = index == stops.length - 1;
              final isDestination =
                  stop.storeName == 'Customer Location' || isLast;

              // ── Step states ──────────────────────────────────────────────
              final isCompleted = index < activeStep;
              final isCurrent = index == activeStep;
              final isUpcoming = index > activeStep;

              final title =
                  isDestination ? destTitle : (stop.storeName ?? 'Store');
              final subtitle = isDestination
                  ? destSubtitle
                  : [stop.address, stop.landmark, stop.city]
                      .whereType<String>()
                      .where((s) => s.trim().isNotEmpty)
                      .join(', ');

              const double iconSize = 44;
              const double lineWidth = 2;
              const double lineHeight = 40;

              // ── Colors per state ─────────────────────────────────────────
              final Color iconBg = (isDelivered || isCompleted)
                  ? AppTheme.primaryColor.withValues(alpha: 0.12)
                  : isCurrent
                      ? Colors.grey.withValues(alpha: 0.18)
                      : Colors.grey.shade100;

              final Color iconBorder = (isDelivered || isCompleted)
                  ? AppTheme.primaryColor
                  : isCurrent
                      ? Colors.grey.shade300
                      : Colors.grey.shade300;

              final Color iconColor = (isDelivered || isCompleted)
                  ? AppTheme.primaryColor
                  : isCurrent
                      ? AppTheme.primaryColor
                      : Colors.grey.shade400;

              final Color lineColor = (isDelivered || isCompleted)
                  ? AppTheme.primaryColor
                  : Colors.grey.shade300;

              final Color titleColor = (isDelivered || !isUpcoming)
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.grey.shade500;

              // ── Animate entry: slide + fade staggered by index ────────────
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 120)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Left column: icon + connector line ──────────────────
                    SizedBox(
                      width: iconSize,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pulse animation only on current active step
                          if (isCurrent && !isDelivered)
                            PulsingIcon(
                              color: iconBg,
                              size: iconSize,
                              child: Icon(
                                isDestination
                                    ? Icons.location_pin
                                    : Icons.store,
                                size: 18,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          else
                            // Completed: show checkmark; upcoming: show step icon
                            Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: iconBg,
                                border: Border.all(
                                  color: iconBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                isDestination
                                    ? stop.isCollected! ? TablerIcons.map_pin_check : RemixIcons.account_pin_circle_fill
                                    : stop.isCollected! ? TablerIcons.check : Icons.store,
                                size: 18,
                                color: iconColor,
                              ),
                            ),

                          // Connector line with animated fill for completed segments
                          if (!isLast)
                            AnimatedPulsingLine(
                              height: lineHeight,
                              width: lineWidth,
                              filled: isCompleted,
                              activeColor: lineColor,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ── Right column: title + subtitle ───────────────────────
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: (iconSize / 2) - 18,
                          bottom: isLast ? (iconSize / 2) - 13 : lineHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: titleColor,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle.trim().isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  height: 1.3,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
