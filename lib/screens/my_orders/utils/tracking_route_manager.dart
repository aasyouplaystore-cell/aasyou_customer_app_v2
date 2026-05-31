import 'dart:developer';
import 'package:latlong2/latlong.dart';
import '../model/delivery_tracking_model.dart';
import '../widgets/road_route.dart';
import 'delivery_math_utils.dart';
import 'delivery_route_utils.dart';

class TrackingRouteManager {
  List<LatLng> staticRoutePoints = [];
  int lastRouteIndex = 0;
  final List<LatLng> travelledPath = [];
  Set<dynamic> previouslyCollectedStopIds = {};
  bool hasDrawnStaticRoute = false;
  bool pickupReached = false;
  bool isRerouting = false;

  LatLng? customerLocation;
  LatLng? pickupLocation;
  LatLng? deliveryPartnerLocation;

  double currentBearing = 0.0;

  static const double offRouteThresholdMeters = 10.0;
  static const double minMovementMeters = 2.0;
  static const int offRouteConsecutiveLimit = 1;
  static const Duration rerouteCooldown = Duration(seconds: 15);
  static const double bridgeDistanceThreshold = 500.0;

  int _offRouteCount = 0;
  DateTime? _lastRerouteTime;

  RouteDetail? getCustomerStop(List<RouteDetail> allStops) {
    final reversed = allStops.reversed.toList();
    try {
      return reversed.firstWhere(
        (s) =>
            (s.storeName ?? '').toLowerCase().contains('customer') ||
            (s.storeName ?? '').toLowerCase().contains('custom'),
      );
    } catch (_) {
      return allStops.isNotEmpty ? allStops.last : null;
    }
  }

  List<RouteDetail> getPendingStoreStops(List<RouteDetail> allStops) {
    return allStops.where((s) {
      final name = (s.storeName ?? '').toLowerCase();
      final isCustomer =
          name.contains('customer') || name.contains('custom');
      return !isCustomer && !(s.isCollected ?? false);
    }).toList();
  }

  List<LatLng> buildOrderedWaypoints(
      LatLng riderGPS, List<RouteDetail> allStops) {
    final pendingStores = getPendingStoreStops(allStops);
    final customerStop = getCustomerStop(allStops);
    final waypoints = <LatLng>[riderGPS];

    for (final store in pendingStores) {
      final lat = store.latitude;
      final lng = store.longitude;
      if (lat != null && lng != null && lat.isFinite && lng.isFinite) {
        waypoints.add(LatLng(lat, lng));
      }
    }

    if (customerStop != null &&
        customerStop.latitude != null &&
        customerStop.longitude != null &&
        customerStop.latitude!.isFinite &&
        customerStop.longitude!.isFinite) {
      final customerLatLng =
          LatLng(customerStop.latitude!, customerStop.longitude!);
      if (waypoints.isEmpty || waypoints.last != customerLatLng) {
        waypoints.add(customerLatLng);
      }
    }

    log('Waypoints built: ${waypoints.length} points '
        '(${pendingStores.length} pending stores)');
    return waypoints;
  }

  List<LatLng> buildBridgeWaypoints(
      LatLng markerPos, LatLng riderGPS, List<RouteDetail> allStops) {
    final pendingStores = getPendingStoreStops(allStops);
    final customerStop = getCustomerStop(allStops);
    final waypoints = <LatLng>[markerPos, riderGPS];

    for (final store in pendingStores) {
      final lat = store.latitude;
      final lng = store.longitude;
      if (lat != null && lng != null && lat.isFinite && lng.isFinite) {
        waypoints.add(LatLng(lat, lng));
      }
    }

    if (customerStop != null &&
        customerStop.latitude != null &&
        customerStop.longitude != null &&
        customerStop.latitude!.isFinite &&
        customerStop.longitude!.isFinite) {
      final customerLatLng =
          LatLng(customerStop.latitude!, customerStop.longitude!);
      if (waypoints.last != customerLatLng) {
        waypoints.add(customerLatLng);
      }
    }

    log('Bridge waypoints built: ${waypoints.length} points');
    return waypoints;
  }

  void extractLocations(List<RouteDetail> allStops) {
    if (customerLocation == null) {
      final customerStop = getCustomerStop(allStops);
      if (customerStop != null &&
          customerStop.latitude != null &&
          customerStop.longitude != null &&
          customerStop.latitude!.isFinite &&
          customerStop.longitude!.isFinite) {
        customerLocation =
            LatLng(customerStop.latitude!, customerStop.longitude!);
      }
    }

    if (pickupLocation == null) {
      final pendingStores = getPendingStoreStops(allStops);
      if (pendingStores.isNotEmpty) {
        final first = pendingStores.first;
        if (first.latitude != null &&
            first.longitude != null &&
            first.latitude!.isFinite &&
            first.longitude!.isFinite) {
          pickupLocation = LatLng(first.latitude!, first.longitude!);
        }
      }
    }
  }

  bool detectNewlyCollectedStops(List<RouteDetail> allStops) {
    final nowCollectedIds = <dynamic>{};
    for (int i = 0; i < allStops.length; i++) {
      final s = allStops[i];
      if (s.isCollected == true) {
        nowCollectedIds.add(s.storeId ?? i);
      }
    }
    final newlyCollected =
        nowCollectedIds.difference(previouslyCollectedStopIds);
    final changed = newlyCollected.isNotEmpty;
    previouslyCollectedStopIds = nowCollectedIds;

    if (changed) {
      log('Stop(s) newly collected: $newlyCollected — will rebuild route');
    }
    return changed;
  }

  void checkPickupReached(LatLng riderPos) {
    if (pickupReached || pickupLocation == null) return;
    final dist = calculateDistance(riderPos, pickupLocation!);
    if (dist <= 30.0) {
      pickupReached = true;
      log('Pickup reached');
    }
  }

  bool checkOffRoute(LatLng actualGPS) {
    if (staticRoutePoints.isEmpty || isRerouting) return false;

    final dist = distanceFromRoute(
      point: actualGPS,
      route: staticRoutePoints,
      nearIdx: lastRouteIndex,
      searchWindow: 60,
    );

    log('Distance from route: ${dist.toStringAsFixed(1)} m '
        '(threshold: $offRouteThresholdMeters m)');

    if (dist > offRouteThresholdMeters) {
      _offRouteCount++;
      log('Off-route count: $_offRouteCount / $offRouteConsecutiveLimit');
      if (_offRouteCount >= offRouteConsecutiveLimit) {
        final now = DateTime.now();
        final sinceLastReroute = _lastRerouteTime == null
            ? const Duration(days: 1)
            : now.difference(_lastRerouteTime!);
        if (sinceLastReroute >= rerouteCooldown) {
          _lastRerouteTime = now;
          _offRouteCount = 0;
          return true;
        } else {
          log('Reroute suppressed (cooldown '
              '${sinceLastReroute.inSeconds}s < ${rerouteCooldown.inSeconds}s)');
          _offRouteCount = 0;
        }
      }
    } else {
      _offRouteCount = 0;
    }
    return false;
  }

  void resetOffRouteState() {
    _offRouteCount = 0;
  }

  double getDistanceMarkerToGPS(LatLng actualGPS) {
    if (deliveryPartnerLocation == null) return 0.0;
    return calculateDistance(deliveryPartnerLocation!, actualGPS);
  }

  int findClosestBidirectional({
    required LatLng target,
    required int centerIdx,
    int? searchWindow,
  }) {
    final window = searchWindow ?? staticRoutePoints.length;
    return findClosestIndexBidirectional(
      route: staticRoutePoints,
      target: target,
      centerIdx: centerIdx,
      searchWindow: window,
    );
  }

  Future<bool> fetchAndSetRoute(
      LatLng riderGPS, List<RouteDetail> allStops) async {
    final waypoints = buildOrderedWaypoints(riderGPS, allStops);
    if (waypoints.length < 2) return false;

    try {
      final rawPoints = await getRoadRoute(waypoints);
      final validPoints = rawPoints
          .where((p) => p.latitude.isFinite && p.longitude.isFinite)
          .toList();

      if (validPoints.length < 2) return false;

      staticRoutePoints = validPoints;
      hasDrawnStaticRoute = true;
      return true;
    } catch (e) {
      log('Route fetch failed: $e');
      return false;
    }
  }

  Future<bool> executeBridgeReroute(
      LatLng markerPos, LatLng riderGPS, List<RouteDetail> allStops) async {
    if (isRerouting) return false;
    isRerouting = true;
    log('Bridge reroute from marker $markerPos through rider $riderGPS');

    try {
      final waypoints = buildBridgeWaypoints(markerPos, riderGPS, allStops);
      if (waypoints.length < 2) return false;

      final rawPoints = await getRoadRoute(waypoints);
      final newRoutePoints = rawPoints
          .where((p) => p.latitude.isFinite && p.longitude.isFinite)
          .toList();

      if (newRoutePoints.length < 2) return false;

      staticRoutePoints = newRoutePoints;
      hasDrawnStaticRoute = true;

      final riderIdx = findClosestBidirectional(
        target: riderGPS,
        centerIdx: 0,
      );
      lastRouteIndex = riderIdx;
      deliveryPartnerLocation = staticRoutePoints[riderIdx];

      travelledPath.clear();
      travelledPath.add(deliveryPartnerLocation!);

      return true;
    } catch (e) {
      log('Bridge reroute failed: $e');
      return false;
    } finally {
      isRerouting = false;
    }
  }

  Future<bool> executeFadeReroute(
      LatLng riderGPS, List<RouteDetail> allStops) async {
    if (isRerouting) return false;
    isRerouting = true;
    log('Fade reroute from rider $riderGPS');

    try {
      final waypoints = buildOrderedWaypoints(riderGPS, allStops);
      if (waypoints.length < 2) return false;

      final rawPoints = await getRoadRoute(waypoints);
      final newRoutePoints = rawPoints
          .where((p) => p.latitude.isFinite && p.longitude.isFinite)
          .toList();

      if (newRoutePoints.length < 2) return false;

      staticRoutePoints = newRoutePoints;
      lastRouteIndex = 0;
      hasDrawnStaticRoute = true;
      deliveryPartnerLocation = newRoutePoints[0];

      travelledPath.clear();
      travelledPath.add(newRoutePoints[0]);

      return true;
    } catch (e) {
      log('Fade reroute failed: $e');
      return false;
    } finally {
      isRerouting = false;
    }
  }

  AnimationSegment? computeAnimationSegment(LatLng newGPS) {
    if (staticRoutePoints.isEmpty) return null;

    final newIdx = findClosestIndexForward(
      route: staticRoutePoints,
      target: newGPS,
      fromIdx: lastRouteIndex,
      searchWindow: 120,
    );
    final projectedPos = staticRoutePoints[newIdx];

    if (deliveryPartnerLocation == null) {
      deliveryPartnerLocation = projectedPos;
      lastRouteIndex = newIdx;
      return null;
    }

    final dist = calculateDistance(deliveryPartnerLocation!, projectedPos);

    if (dist < minMovementMeters) {
      deliveryPartnerLocation = projectedPos;
      lastRouteIndex = newIdx;
      return null;
    }

    final segmentPoints =
        staticRoutePoints.sublist(lastRouteIndex, newIdx + 1);

    if (segmentPoints.length < 2) {
      deliveryPartnerLocation = projectedPos;
      lastRouteIndex = newIdx;
      return null;
    }

    final secs = (dist / 8).clamp(4.0, 12.0).toInt();
    return AnimationSegment(
      path: segmentPoints,
      targetRouteIndex: newIdx,
      durationSeconds: secs,
    );
  }

  LatLng interpolatePosition(double t, List<LatLng> path) {
    final total = path.length - 1;
    final idx = (t * total).floor().clamp(0, total - 1);
    final segT = (t * total - idx).clamp(0.0, 1.0);
    final p1 = path[idx];
    final p2 = path[idx + 1];
    return LatLng(
      p1.latitude + segT * (p2.latitude - p1.latitude),
      p1.longitude + segT * (p2.longitude - p1.longitude),
    );
  }

  void updateBearingFromPath(List<LatLng> path, double t) {
    if (path.length < 2) return;
    final total = path.length - 1;
    final idx = (t * total).floor().clamp(0, total - 1);
    final newBearing = calculateBearing(path[idx], path[idx + 1]);
    final diff = (newBearing - currentBearing + 540) % 360 - 180;
    currentBearing = (currentBearing + diff * 0.3) % 360;
  }

  void addToTravelledPath(LatLng pos) {
    if (travelledPath.isEmpty ||
        calculateDistance(travelledPath.last, pos) > 5.0) {
      travelledPath.add(pos);
    }
  }

  void advanceRouteIndex(LatLng pos) {
    if (staticRoutePoints.isEmpty) return;
    lastRouteIndex = findClosestIndexForward(
      route: staticRoutePoints,
      target: pos,
      fromIdx: lastRouteIndex,
      searchWindow: 30,
    );
  }
}

class AnimationSegment {
  final List<LatLng> path;
  final int targetRouteIndex;
  final int durationSeconds;

  const AnimationSegment({
    required this.path,
    required this.targetRouteIndex,
    required this.durationSeconds,
  });
}
