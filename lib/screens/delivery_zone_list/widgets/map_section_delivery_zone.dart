import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../config/helper.dart';
import '../../../config/theme.dart';
import '../model/delivery_zone_detail_model.dart';

Widget buildMapSection({required BuildContext context, required DeliveryZoneDetailData zone}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // Parse center coordinates
  LatLng? centerPosition;
  if (zone.centerLatitude != null && zone.centerLongitude != null) {
    try {
        centerPosition = LatLng(
          double.parse(zone.centerLatitude!.trim()),
          double.parse(zone.centerLongitude!.trim()),
        );
    } catch (e) {
      log('Error parsing coordinates: $e');
    }
  }

  // Default position if parsing fails
  final position = centerPosition ?? const LatLng(23.1217, 69.9956);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      height: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _MapWidget(
          zone: zone,
          centerPosition: position,
          isDark: isDark,
        ),
      ),
    ),
  );
}

// Separate StatefulWidget for map management
class _MapWidget extends StatefulWidget {
  final DeliveryZoneDetailData zone;
  final LatLng centerPosition;
  final bool isDark;

  const _MapWidget({
    required this.zone,
    required this.centerPosition,
    required this.isDark,
  });

  @override
  State<_MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<_MapWidget> {
  GoogleMapController? _mapController;
  final MapType _currentMapType = MapType.normal;
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMapElements();
  }

  void _setupMapElements() {
    // Add center marker
    _markers.add(
      Marker(
        markerId: const MarkerId('center'),
        position: widget.centerPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: widget.zone.name ?? 'Zone Center',
          snippet: 'Delivery Zone Center Point',
        ),
      ),
    );


    if (widget.zone.boundaryJson != null) {
      List<LatLng> polygonPoints = [];
      try {
        for (var point in widget.zone.boundaryJson!) {
          polygonPoints.add(LatLng(point.lat!, point.lng!));
        }

        if (polygonPoints.isNotEmpty) {
          _polygons.add(
            Polygon(
              polygonId: const PolygonId('boundary'),
              points: polygonPoints,
              fillColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              strokeColor: AppTheme.primaryColor,
              strokeWidth: 2,
            ),
          );
        }
      } catch (e) {
        log('Error creating boundary polygon: $e');
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

// void _toggleMapType() {

  void _openFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenMap(
          zone: widget.zone,
          centerPosition: widget.centerPosition,
          isDark: widget.isDark,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: widget.centerPosition,
            zoom: _calculateZoomLevel(widget.zone.radiusKm ?? 10),
          ),
          mapType: _currentMapType,
          markers: _markers,
          polygons: _polygons,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: false,
          style: widget.isDark ? darkMapStyle : null,
        ),

// // Map type toggle

        // Fullscreen button
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildMapButton(
              context,
              Icons.fullscreen_outlined,
              false,
              _openFullScreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton(
      BuildContext context,
      IconData icon,
      bool isActive,
      VoidCallback onPressed,
      ) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: isActive ? AppTheme.primaryColor : theme.colorScheme.tertiary,
            size: 20,
          ),
        ),
      ),
    );
  }

  // Calculate appropriate zoom level based on radius
  double _calculateZoomLevel(double radiusKm) {
    if (radiusKm <= 1) return 14;
    if (radiusKm <= 3) return 13;
    if (radiusKm <= 5) return 12;
    if (radiusKm <= 10) return 11;
    if (radiusKm <= 20) return 10;
    return 9;
  }
}

// Full screen map view
class _FullScreenMap extends StatefulWidget {
  final DeliveryZoneDetailData zone;
  final LatLng centerPosition;
  final bool isDark;

  const _FullScreenMap({
    required this.zone,
    required this.centerPosition,
    required this.isDark,
  });

  @override
  State<_FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<_FullScreenMap> {
  GoogleMapController? _mapController;
  final MapType _currentMapType = MapType.normal;
  final Set<Circle> _circles = {};
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMapElements();
  }

  void _setupMapElements() {
    // Add center marker
    _markers.add(
      Marker(
        markerId: const MarkerId('center'),
        position: widget.centerPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: widget.zone.name ?? 'Zone Center',
          snippet: 'Delivery Zone Center Point',
        ),
      ),
    );

    if (widget.zone.radiusKm != null) {
      _circles.add(
        Circle(
          circleId: const CircleId('coverage'),
          center: widget.centerPosition,
          radius: (widget.zone.radiusKm! * 1000),
          fillColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          strokeColor: AppTheme.primaryColor,
          strokeWidth: 2,
        ),
      );
    }

    if (widget.zone.boundaryJson != null) {
      List<LatLng> polygonPoints = [];
      try {
        for (var point in widget.zone.boundaryJson!) {
          polygonPoints.add(LatLng(point.lat!, point.lng!));
        }

        if (polygonPoints.isNotEmpty) {
          _polygons.add(
            Polygon(
              polygonId: const PolygonId('boundary'),
              points: polygonPoints,
              fillColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              strokeColor: AppTheme.primaryColor,
              strokeWidth: 2,
            ),
          );
        }
      } catch (e) {
        log('Error creating boundary polygon: $e');
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.centerPosition,
              zoom: _calculateZoomLevel(widget.zone.radiusKm ?? 10),
            ),
            mapType: _currentMapType,
            markers: _markers,
            // circles: _circles,
            polygons: _polygons,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
            style: widget.isDark ? darkMapStyle : null,
          ),

          // Close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: theme.colorScheme.tertiary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateZoomLevel(double radiusKm) {
    if (radiusKm <= 1) return 14;
    if (radiusKm <= 3) return 13;
    if (radiusKm <= 5) return 12;
    if (radiusKm <= 10) return 11;
    if (radiusKm <= 20) return 10;
    return 9;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}