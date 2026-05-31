import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../config/theme.dart';
import 'dashed_curve_polyline.dart';

class AnimatedDashedRoute extends StatefulWidget {
  final LatLng deliveryBoyLocation;
  final List<LatLng> storeLocations; // ordered list of stores
  final LatLng customerLocation;

  const AnimatedDashedRoute({
    super.key,
    required this.deliveryBoyLocation,
    required this.storeLocations,
    required this.customerLocation,
  });

  @override
  State<AnimatedDashedRoute> createState() => _AnimatedDashedRouteState();
}

class _AnimatedDashedRouteState extends State<AnimatedDashedRoute>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _isValidLatLng(LatLng? p) {
    if (p == null) return false;
    if (p.latitude.isNaN  || p.longitude.isNaN)      return false;
    if (p.latitude.isInfinite || p.longitude.isInfinite) return false;
    if (p.latitude == 0.0 && p.longitude == 0.0)     return false;
    return true;
  }

  /// Build ordered waypoints: rider → stores → customer
  List<LatLng> get _waypoints {
    final points = <LatLng>[];
    if (_isValidLatLng(widget.deliveryBoyLocation)) {
      points.add(widget.deliveryBoyLocation);
    }
    for (final s in widget.storeLocations) {
      if (_isValidLatLng(s)) points.add(s);
    }
    if (_isValidLatLng(widget.customerLocation)) {
      points.add(widget.customerLocation);
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final waypoints = _waypoints;
    if (waypoints.length < 2) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Stack(
        children: [
          // Draw a dashed curved arc between each consecutive pair
          for (int i = 0; i < waypoints.length - 1; i++)
            Opacity(
              opacity: _opacity.value,
              child: DashedCurvedPolyline(
                from: waypoints[i],
                to: waypoints[i + 1],
                color: AppTheme.primaryColor,
                strokeWidth: 3,
                dashCount: 10,
              ),
            ),

          // Dot markers at each waypoint
          MarkerLayer(
            markers: waypoints.asMap().entries.map((e) {
              final isFirst = e.key == 0;
              final isLast  = e.key == waypoints.length - 1;
              return Marker(
                point: e.value,
                width: 16,
                height: 16,
                child: Opacity(
                  opacity: _opacity.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFirst
                          ? Colors.blue
                          : isLast
                          ? AppTheme.primaryColor
                          : Colors.orange,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}