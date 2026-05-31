import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'delivery_math_utils.dart';

List<LatLng> generateCurvedPath(LatLng start, LatLng end, {int segments = 50}) {
  final List<LatLng> points = [];
  for (int i = 0; i <= segments; i++) {
    final t = i / segments;
    points.add(getCurvePoint(start, end, t));
  }
  return points;
}

LatLng getCurvePoint(LatLng start, LatLng end, double t) {
  final lat = start.latitude + (end.latitude - start.latitude) * t;
  final lng = start.longitude + (end.longitude - start.longitude) * t;

  final dLon = end.longitude - start.longitude;
  final dLat = end.latitude - start.latitude;

  final perpLat = -dLon * 0.2;
  final perpLng = dLat * 0.2;

  return LatLng(
    lat + perpLat * math.sin(t * math.pi),
    lng + perpLng * math.sin(t * math.pi),
  );
}

int findClosestIndexForward({
  required List<LatLng> route,
  required LatLng target,
  required int fromIdx,
  int searchWindow = 120,
}) {
  final start = fromIdx.clamp(0, route.length - 1);
  final end = (fromIdx + searchWindow).clamp(0, route.length - 1);
  double minDist = double.infinity;
  int closestIdx = start;

  for (int i = start; i <= end; i++) {
    final d = calculateDistance(route[i], target);
    if (d < minDist) {
      minDist = d;
      closestIdx = i;
    }
  }
  return closestIdx;
}

int findClosestIndexBidirectional({
  required List<LatLng> route,
  required LatLng target,
  required int centerIdx,
  int searchWindow = 120,
}) {
  final start = (centerIdx - searchWindow).clamp(0, route.length - 1);
  final end = (centerIdx + searchWindow).clamp(0, route.length - 1);
  double minDist = double.infinity;
  int closestIdx = centerIdx;

  for (int i = start; i <= end; i++) {
    final d = calculateDistance(route[i], target);
    if (d < minDist) {
      minDist = d;
      closestIdx = i;
    }
  }
  return closestIdx;
}
