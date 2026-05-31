import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:aasyou/config/theme.dart';
import 'package:latlong2/latlong.dart';
import '../model/delivery_tracking_model.dart';
import '../utils/delivery_icon_painter.dart';
import '../utils/delivery_math_utils.dart';
import '../utils/delivery_route_utils.dart';
import '../utils/tracking_route_manager.dart';

class TrackingMapWidget extends StatefulWidget {
  final TrackingRouteManager routeManager;
  final DeliveryBoyTrackingModel? tracking;
  final VoidCallback onRefreshTap;

  const TrackingMapWidget({
    super.key,
    required this.routeManager,
    required this.tracking,
    required this.onRefreshTap,
  });

  @override
  State<TrackingMapWidget> createState() => TrackingMapWidgetState();
}

class TrackingMapWidgetState extends State<TrackingMapWidget>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _moveController;
  late final AnimationController _fadeController;
  late final CurvedAnimation _curvedMove;

  Uint8List? _meIconBytes;
  Uint8List? _storeIconBytes;
  Uint8List? _deliveryBoyIconBytes;

  double _followZoom = 15.5;
  bool _isInitialLoad = true;

  List<LatLng> _animationPath = [];
  int _animationTargetRouteIndex = 0;

  List<LatLng> _curvedPathPoints = [];

  double _markerOpacity = 1.0;
  int _lastMapMoveMs = 0;

  List<Marker>? _cachedMarkers;
  List<Polyline>? _cachedPolylines;
  bool _markersNeedRebuild = true;
  bool _polylinesNeedRebuild = true;

  TrackingRouteManager get _rm => widget.routeManager;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _moveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )
      ..addListener(_onMoveTick)
      ..addStatusListener(_onMoveStatusChanged);

    _curvedMove = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOut,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1.0,
    )..addListener(() {
        _markerOpacity = _fadeController.value;
        if (mounted) setState(() {});
      });

    _loadIcons();
  }

  Future<void> _loadIcons() async {
    try {
      final data =
          await rootBundle.load('assets/images/delivery-boy-top-view.png');
      final resized = await _resizeImage(data.buffer.asUint8List(), 100, 100);
      if (mounted) setState(() => _deliveryBoyIconBytes = resized);
    } catch (e) {
      debugPrint('Delivery icon load failed: $e');
    }

    final meBytes = await buildCustomerIconBytes(size: 80);
    if (mounted) setState(() => _meIconBytes = meBytes);

    final storeBytes = await buildStoreIconBytes(size: 80);
    if (mounted) setState(() => _storeIconBytes = storeBytes);
  }

  Future<Uint8List> _resizeImage(Uint8List data, int w, int h) async {
    final codec =
        await ui.instantiateImageCodec(data, targetWidth: w, targetHeight: h);
    final frame = await codec.getNextFrame();
    final byteData =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> processTrackingUpdate(DeliveryBoyTrackingModel tracking) async {
    final allStops = tracking.data?.route?.routeDetails ?? [];
    final deliveryBoys = tracking.data?.deliveryBoys ?? [];

    _rm.extractLocations(allStops);
    final collectionsChanged = _rm.detectNewlyCollectedStops(allStops);

    LatLng? newPos;
    if (deliveryBoys.isNotEmpty) {
      final boyData = deliveryBoys.first.data;
      final lat = double.tryParse(boyData?.latitude?.toString() ?? '');
      final lng = double.tryParse(boyData?.longitude?.toString() ?? '');
      if (lat != null && lng != null && lat.isFinite && lng.isFinite) {
        newPos = LatLng(lat, lng);
      }
    }

    if (newPos == null) {
      _handleNoDeliveryBoy();
      return;
    }

    _curvedPathPoints = [];
    _rm.checkPickupReached(newPos);

    final needsInitial = !_rm.hasDrawnStaticRoute;
    final needsRebuild = collectionsChanged && _rm.hasDrawnStaticRoute;

    if (needsInitial || needsRebuild) {
      _stopAnimation();
      final success = await _rm.fetchAndSetRoute(newPos, allStops);
      if (!mounted) return;

      if (success) {
        _rm.resetOffRouteState();
        if (!needsRebuild) {
          final initialIdx = _rm.findClosestBidirectional(
            target: newPos,
            centerIdx: 0,
          );
          _rm.lastRouteIndex = initialIdx;
          _rm.deliveryPartnerLocation = _rm.staticRoutePoints[initialIdx];
          _rm.travelledPath
            ..clear()
            ..add(_rm.deliveryPartnerLocation!);
        } else {
          _rm.lastRouteIndex = _rm.deliveryPartnerLocation != null
              ? _rm.findClosestBidirectional(
                  target: _rm.deliveryPartnerLocation!,
                  centerIdx: 0,
                )
              : 0;
        }
        _invalidateCache();
      }
    }

    if (_rm.staticRoutePoints.isEmpty) {
      _stopAnimation();
      await _rm.executeFadeReroute(newPos, allStops);
      if (!mounted) return;
      _invalidateCache();
    } else {
      final shouldReroute = _rm.checkOffRoute(newPos);
      if (shouldReroute) {
        _stopAnimation();
        await _handleReroute(newPos, allStops);
        if (!mounted) return;
      } else {
        _animateToNewPosition(newPos);
      }
    }

    if (_isInitialLoad && mounted) {
      _followZoom = 15.5;
      _isInitialLoad = false;
      _followRider(_rm.deliveryPartnerLocation ?? newPos);

      if (_rm.pickupLocation != null) {
        _rm.currentBearing = calculateBearing(
            _rm.pickupLocation!, _rm.deliveryPartnerLocation ?? newPos);
      } else if (_rm.customerLocation != null) {
        _rm.currentBearing = calculateBearing(
            _rm.customerLocation!, _rm.deliveryPartnerLocation ?? newPos);
      }
    }

    _followRider(_rm.deliveryPartnerLocation ?? newPos);
    _invalidateCache();
    if (mounted) setState(() {});
  }

  Future<void> _handleReroute(LatLng newPos, List<RouteDetail> allStops) async {
    _rm.staticRoutePoints = [];
    _invalidateCache();
    if (mounted) setState(() {});

    final dist = _rm.getDistanceMarkerToGPS(newPos);

    if (dist < TrackingRouteManager.bridgeDistanceThreshold) {
      final markerPos = _rm.deliveryPartnerLocation ?? newPos;
      final success =
          await _rm.executeBridgeReroute(markerPos, newPos, allStops);
      if (!mounted) return;
      if (success) _invalidateCache();
    } else {
      await _fadeController.reverse();
      if (!mounted) return;

      final success = await _rm.executeFadeReroute(newPos, allStops);
      if (!mounted) return;

      if (success) _invalidateCache();
      await _fadeController.forward();
      if (!mounted) return;
    }

    if (mounted) setState(() {});
  }

  void _stopAnimation() {
    _moveController.stop();
    _animationPath = [];
    _animationTargetRouteIndex = 0;
  }

  void _animateToNewPosition(LatLng newGPS) {
    final segment = _rm.computeAnimationSegment(newGPS);
    if (segment == null) {
      _polylinesNeedRebuild = true;
      if (mounted) setState(() {});
      return;
    }

    if (_moveController.isAnimating) {
      _animationTargetRouteIndex = segment.targetRouteIndex;
      return;
    }

    _animationTargetRouteIndex = segment.targetRouteIndex;
    _animationPath = segment.path;
    _moveController
      ..duration = Duration(seconds: segment.durationSeconds)
      ..reset()
      ..forward();
  }

  void _onMoveTick() {
    if (_animationPath.length < 2) return;
    final t = _curvedMove.value;
    if (t >= 1.0) return;

    final pos = _rm.interpolatePosition(t, _animationPath);
    _rm.updateBearingFromPath(_animationPath, t);
    _rm.deliveryPartnerLocation = pos;

    _followRider(pos);
    _rm.advanceRouteIndex(pos);
    _rm.addToTravelledPath(pos);

    _markersNeedRebuild = true;
    _polylinesNeedRebuild = true;
    if (mounted) setState(() {});
  }

  void _onMoveStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_rm.staticRoutePoints.isNotEmpty &&
          _animationTargetRouteIndex < _rm.staticRoutePoints.length) {
        _rm.lastRouteIndex = _animationTargetRouteIndex;
        _rm.deliveryPartnerLocation =
            _rm.staticRoutePoints[_animationTargetRouteIndex];
      }
      _animationPath = [];
      _invalidateCache();
      if (mounted) setState(() {});
    }
  }

  void _handleNoDeliveryBoy() {
    if (_rm.pickupLocation != null && _rm.customerLocation != null) {
      _curvedPathPoints =
          generateCurvedPath(_rm.pickupLocation!, _rm.customerLocation!);
      final bounds =
          LatLngBounds(_rm.pickupLocation!, _rm.customerLocation!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50),
            ),
          );
        }
      });
    } else {
      _curvedPathPoints = [];
    }
    _invalidateCache();
    if (mounted) setState(() {});
  }

  void _followRider(LatLng position) {
    if (!mounted ||
        !position.latitude.isFinite ||
        !position.longitude.isFinite ||
        !_followZoom.isFinite) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastMapMoveMs < 100) return;
    _lastMapMoveMs = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mapController.move(position, _followZoom);
    });
  }

  void _invalidateCache() {
    _markersNeedRebuild = true;
    _polylinesNeedRebuild = true;
  }

  List<Marker> _buildMarkers() {
    if (!_markersNeedRebuild && _cachedMarkers != null) {
      return _cachedMarkers!;
    }

    final markers = <Marker>[];

    if (_rm.customerLocation != null && _meIconBytes != null) {
      markers.add(Marker(
        point: _rm.customerLocation!,
        width: 40,
        height: 40,
        child: Image.memory(_meIconBytes!),
      ));
    }

    if (_rm.deliveryPartnerLocation != null && _deliveryBoyIconBytes != null) {
      markers.add(Marker(
        point: _rm.deliveryPartnerLocation!,
        width: 50,
        height: 50,
        child: Opacity(
          opacity: _markerOpacity,
          child: Transform.rotate(
            angle: _rm.currentBearing * math.pi / 180,
            alignment: Alignment.center,
            child: Image.memory(_deliveryBoyIconBytes!),
          ),
        ),
      ));
    }

    if (_storeIconBytes != null && widget.tracking != null) {
      final allStops = widget.tracking!.data?.route?.routeDetails ?? [];
      final pendingStores = _rm.getPendingStoreStops(allStops);

      for (final store in pendingStores) {
        final lat = store.latitude;
        final lng = store.longitude;
        if (lat != null && lng != null && lat.isFinite && lng.isFinite) {
          markers.add(Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: Image.memory(_storeIconBytes!),
          ));
        }
      }
    } else if (_rm.pickupLocation != null && _storeIconBytes != null) {
      markers.add(Marker(
        point: _rm.pickupLocation!,
        width: 40,
        height: 40,
        child: Image.memory(_storeIconBytes!),
      ));
    }

    _cachedMarkers = markers;
    _markersNeedRebuild = false;
    return markers;
  }

  List<Polyline> _buildPolylines() {
    if (!_polylinesNeedRebuild && _cachedPolylines != null) {
      return _cachedPolylines!;
    }

    final polylines = <Polyline>[];

    if (_rm.travelledPath.length >= 2) {
      polylines.add(Polyline(
        points: List.of(_rm.travelledPath),
        color: Colors.grey.shade400,
        strokeWidth: 4.0,
      ));
    }

    if (_rm.staticRoutePoints.isNotEmpty) {
      final remaining = _rm.staticRoutePoints.sublist(_rm.lastRouteIndex);
      final pts = <LatLng>[];
      if (_rm.deliveryPartnerLocation != null) {
        pts.add(_rm.deliveryPartnerLocation!);
      }
      pts.addAll(remaining);

      if (pts.length >= 2) {
        polylines.add(Polyline(
          points: pts,
          color: AppTheme.primaryColor,
          strokeWidth: 5.0,
        ));
      }
    }

    polylines.addAll(_buildCurvedDashedPolylines());

    _cachedPolylines = polylines;
    _polylinesNeedRebuild = false;
    return polylines;
  }

  List<Polyline> _buildCurvedDashedPolylines() {
    if (_curvedPathPoints.isEmpty) return [];

    final dashes = <Polyline>[];
    const int dashLength = 2;
    const int gapLength = 2;

    for (int i = 0;
        i < _curvedPathPoints.length - 1;
        i += (dashLength + gapLength)) {
      final int end =
          math.min(i + dashLength, _curvedPathPoints.length - 1);
      if (end > i) {
        dashes.add(Polyline(
          points: _curvedPathPoints.sublist(i, end + 1),
          color: AppTheme.primaryColor,
          strokeWidth: 3,
        ));
      }
    }
    return dashes;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(28.6139, 77.2090),
            initialZoom: 15.0,
            minZoom: 3,
            maxZoom: 18,
            keepAlive: true,
            interactionOptions: const InteractionOptions(),
            onMapEvent: (event) {
              if (event is MapEventMove && event.camera.zoom.isFinite) {
                _followZoom = event.camera.zoom;
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/'
                  'World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.aasyou.user',
            ),
            PolylineLayer(polylines: _buildPolylines()),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
        PositionedDirectional(
          top: 12,
          end: 10,
          child: _RefreshButton(onTap: widget.onRefreshTap),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _curvedMove.dispose();
    _moveController.dispose();
    _fadeController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RefreshButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: const Icon(Icons.refresh, color: AppTheme.primaryColor),
      ),
    );
  }
}
