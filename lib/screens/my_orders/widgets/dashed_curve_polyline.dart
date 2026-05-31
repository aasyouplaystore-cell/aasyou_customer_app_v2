import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DashedCurvedPolyline extends StatelessWidget {
  final LatLng from;
  final LatLng to;
  final Color color;
  final double strokeWidth;
  final int dashCount;        // number of dash segments
  final int curvePoints;      // smoothness of the arc

  const DashedCurvedPolyline({
    super.key,
    required this.from,
    required this.to,
    this.color = Colors.grey,
    this.strokeWidth = 3,
    this.dashCount = 12,
    this.curvePoints = 40,
  });

  /// Generate a bezier curved arc between two LatLngs
  List<LatLng> _generateCurvedPoints() {
    final List<LatLng> points = [];

    final double midLat = (from.latitude + to.latitude) / 2;
    final double midLng = (from.longitude + to.longitude) / 2;

    // Perpendicular offset to create the curve bulge
    final double dLat = to.latitude - from.latitude;
    final double dLng = to.longitude - from.longitude;
    const double curveOffset = 0.3; // tweak for more/less curve

    final double controlLat = midLat - dLng * curveOffset;
    final double controlLng = midLng + dLat * curveOffset;

    // Quadratic bezier interpolation
    for (int i = 0; i <= curvePoints; i++) {
      final double t = i / curvePoints;
      final double lat = (1 - t) * (1 - t) * from.latitude +
          2 * (1 - t) * t * controlLat +
          t * t * to.latitude;
      final double lng = (1 - t) * (1 - t) * from.longitude +
          2 * (1 - t) * t * controlLng +
          t * t * to.longitude;
      points.add(LatLng(lat, lng));
    }

    return points;
  }

  /// Split full curve into alternating dash/gap segments
  List<List<LatLng>> _buildDashSegments(List<LatLng> allPoints) {
    final segments = <List<LatLng>>[];
    final int pointsPerDash = (allPoints.length / (dashCount * 2)).floor().clamp(1, 999);

    for (int i = 0; i < allPoints.length; i += pointsPerDash * 2) {
      final end = (i + pointsPerDash).clamp(0, allPoints.length);
      segments.add(allPoints.sublist(i, end));
    }
    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final curvedPoints = _generateCurvedPoints();
    final dashSegments = _buildDashSegments(curvedPoints);

    return PolylineLayer(
      polylines: dashSegments
          .where((seg) => seg.length >= 2)
          .map((seg) => Polyline(
        points: seg,
        color: color,
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
      ))
          .toList(),
    );
  }
}