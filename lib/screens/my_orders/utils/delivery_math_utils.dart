import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

extension NumExt on num {
  double get toRadians => this * (math.pi / 180);
}

double calculateDistance(LatLng a, LatLng b) {
  const r = 6371000.0;
  final dLat = (b.latitude - a.latitude).toRadians;
  final dLng = (b.longitude - a.longitude).toRadians;
  final aa = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(a.latitude.toRadians) *
          math.cos(b.latitude.toRadians) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return r * 2 * math.atan2(math.sqrt(aa), math.sqrt(1 - aa));
}

double calculateBearing(LatLng start, LatLng end) {
  final lat1 = start.latitude * math.pi / 180;
  final lon1 = start.longitude * math.pi / 180;
  final lat2 = end.latitude * math.pi / 180;
  final lon2 = end.longitude * math.pi / 180;
  final dLon = lon2 - lon1;
  final y = math.sin(dLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

double distanceFromRoute({
  required LatLng point,
  required List<LatLng> route,
  required int nearIdx,
  int searchWindow = 60,
}) {
  if (route.isEmpty) return double.infinity;
  final start = (nearIdx - searchWindow).clamp(0, route.length - 1);
  final end = (nearIdx + searchWindow).clamp(0, route.length - 2);
  double minD = double.infinity;

  for (int i = start; i <= end; i++) {
    final d = pointToSegmentDistance(point, route[i], route[i + 1]);
    if (d < minD) minD = d;
  }
  return minD;
}

double pointToSegmentDistance(LatLng p, LatLng a, LatLng b) {
  final dx = b.longitude - a.longitude;
  final dy = b.latitude - a.latitude;
  final lenSq = dx * dx + dy * dy;
  if (lenSq == 0) return calculateDistance(p, a);

  final t = ((p.longitude - a.longitude) * dx + (p.latitude - a.latitude) * dy) /
      lenSq;
  final clamped = t.clamp(0.0, 1.0);
  final closest = LatLng(
    a.latitude + clamped * dy,
    a.longitude + clamped * dx,
  );
  return calculateDistance(p, closest);
}
