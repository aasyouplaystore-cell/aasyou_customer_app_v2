import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnimatedRouteLayer extends StatefulWidget {
  final List<LatLng> remainingPoints;
  final List<LatLng> travelledPoints;
  final Color routeColor;
  final Color travelledColor;
  final double routeStrokeWidth;
  final double travelledStrokeWidth;

  const AnimatedRouteLayer({
    super.key,
    required this.remainingPoints,
    this.travelledPoints = const [],
    required this.routeColor,
    this.travelledColor = const Color(0xFFBDBDBD),
    this.routeStrokeWidth = 5.0,
    this.travelledStrokeWidth = 3.0,
  });

  @override
  State<AnimatedRouteLayer> createState() => _AnimatedRouteLayerState();
}

class _AnimatedRouteLayerState extends State<AnimatedRouteLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          size: Size(camera.size.width, camera.size.height),
          isComplex: true,
          painter: _RoutePainter(
            remainingPoints: widget.remainingPoints,
            travelledPoints: widget.travelledPoints,
            routeColor: widget.routeColor,
            travelledColor: widget.travelledColor,
            routeStrokeWidth: widget.routeStrokeWidth,
            travelledStrokeWidth: widget.travelledStrokeWidth,
            dashPhase: _controller.value,
            camera: camera,
          ),
        );
      },
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<LatLng> remainingPoints;
  final List<LatLng> travelledPoints;
  final Color routeColor;
  final Color travelledColor;
  final double routeStrokeWidth;
  final double travelledStrokeWidth;
  final double dashPhase;
  final MapCamera camera;

  static const double _dashLen = 14.0;
  static const double _gapLen = 10.0;
  static const double _travelDashLen = 4.0;
  static const double _travelGapLen = 6.0;

  _RoutePainter({
    required this.remainingPoints,
    required this.travelledPoints,
    required this.routeColor,
    required this.travelledColor,
    required this.routeStrokeWidth,
    required this.travelledStrokeWidth,
    required this.dashPhase,
    required this.camera,
  });

  Offset _toScreen(LatLng point) {
    return camera.latLngToScreenOffset(point);
  }

  List<Offset> _toScreenPoints(List<LatLng> points) {
    return points.map(_toScreen).toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawTravelledRoute(canvas);
    _drawRemainingRouteOutline(canvas);
    _drawRemainingRouteDashes(canvas);
  }

  void _drawTravelledRoute(Canvas canvas) {
    if (travelledPoints.length < 2) return;

    final screenPts = _toScreenPoints(travelledPoints);
    final paint = Paint()
      ..color = travelledColor.withValues(alpha: 0.40)
      ..strokeWidth = travelledStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(
      canvas,
      screenPts,
      paint,
      _travelDashLen,
      _travelGapLen,
      0.0,
    );
  }

  void _drawRemainingRouteOutline(Canvas canvas) {
    if (remainingPoints.length < 2) return;

    final screenPts = _toScreenPoints(remainingPoints);
    final path = _buildSmoothPath(screenPts);

    final borderPaint = Paint()
      ..color = routeColor.withValues(alpha: 0.18)
      ..strokeWidth = routeStrokeWidth + 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, borderPaint);
  }

  void _drawRemainingRouteDashes(Canvas canvas) {
    if (remainingPoints.length < 2) return;

    final screenPts = _toScreenPoints(remainingPoints);
    const totalCycle = _dashLen + _gapLen;
    final offset = dashPhase * totalCycle;

    final paint = Paint()
      ..color = routeColor
      ..strokeWidth = routeStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, screenPts, paint, _dashLen, _gapLen, offset);
  }

  /// Draws a dashed polyline through [points] with the given dash/gap pattern.
  void _drawDashedPath(
    Canvas canvas,
    List<Offset> points,
    Paint paint,
    double dashLen,
    double gapLen,
    double offset,
  ) {
    if (points.length < 2) return;

    final totalCycle = dashLen + gapLen;
    double distance = -offset;
    bool drawing = true;
    double remaining = dashLen;

    // Advance past negative offset
    if (distance < 0) {
      final skip = -distance;
      if (skip < dashLen) {
        remaining = dashLen - skip;
        drawing = true;
      } else {
        remaining = totalCycle - skip;
        drawing = false;
      }
      distance = 0;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final segDx = p2.dx - p1.dx;
      final segDy = p2.dy - p1.dy;
      final segLen = math.sqrt(segDx * segDx + segDy * segDy);
      if (segLen < 0.5) continue;

      final ux = segDx / segLen;
      final uy = segDy / segLen;

      double consumed = 0.0;

      while (consumed < segLen) {
        final available = segLen - consumed;
        final step = math.min(remaining, available);

        if (drawing && step > 0.5) {
          final startX = p1.dx + ux * consumed;
          final startY = p1.dy + uy * consumed;
          final endX = p1.dx + ux * (consumed + step);
          final endY = p1.dy + uy * (consumed + step);
          canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
        }

        consumed += step;
        remaining -= step;

        if (remaining <= 0.001) {
          drawing = !drawing;
          remaining = drawing ? dashLen : gapLen;
        }
      }
    }
  }

  ui.Path _buildSmoothPath(List<Offset> points) {
    final path = ui.Path();
    if (points.isEmpty) return path;
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) {
    return dashPhase != oldDelegate.dashPhase ||
        remainingPoints != oldDelegate.remainingPoints ||
        travelledPoints != oldDelegate.travelledPoints ||
        camera != oldDelegate.camera;
  }
}
