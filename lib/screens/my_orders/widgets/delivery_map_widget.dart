import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class DeliveryMapWidget extends StatelessWidget {
  final MapController mapController;
  final MapOptions mapOptions;
  final Polyline? travelledPolyline;
  final Polyline? remainingPolyline;
  final List<Polyline> curvedDashedPolylines;
  final List<Marker> markers;
  final bool isDelivered;
  final ConfettiController confettiController;

  const DeliveryMapWidget({
    super.key,
    required this.mapController,
    required this.mapOptions,
    required this.travelledPolyline,
    required this.remainingPolyline,
    required this.curvedDashedPolylines,
    required this.markers,
    required this.isDelivered,
    required this.confettiController,
  });

  @override
  Widget build(BuildContext context) {
    if (isDelivered) {
      return _buildSuccessAnimation();
    }

    return FlutterMap(
      mapController: mapController,
      options: mapOptions,
      children: [
        TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/'
              'World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.aasyou.user',
        ),
        PolylineLayer(
          polylines: [
            if (travelledPolyline != null) travelledPolyline!,
            if (remainingPolyline != null) remainingPolyline!,
            ...curvedDashedPolylines,
          ],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            createParticlePath: _drawStar,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delivered!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been successfully delivered',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ui.Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = ui.Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(
          halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
