import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

Future<Uint8List> buildCustomerIconBytes({int size = 80}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );
  final s = size.toDouble();
  final center = Offset(s / 2, s / 2 - 6);

  canvas.drawCircle(
    Offset(s / 2, s / 2 + 4),
    s * 0.32,
    Paint()
      ..color = const Color(0xFF1565C0).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
  );
  canvas.drawCircle(center, s * 0.40,
      Paint()..color = const Color(0xFF2196F3).withValues(alpha: 0.22));
  canvas.drawCircle(center, s * 0.30, Paint()..color = Colors.white);
  canvas.drawCircle(
    center,
    s * 0.26,
    Paint()
      ..shader = ui.Gradient.radial(
        Offset(center.dx - 3, center.dy - 3),
        s * 0.26,
        [const Color(0xFF42A5F5), const Color(0xFF1565C0)],
      ),
  );
  _drawPersonIcon(canvas, center, s * 0.22, Colors.white);
  _drawAnchorTriangle(canvas, s, center, s * 0.10, s * 0.24, s * 0.30,
      const Color(0xFF1565C0));

  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return pngBytes!.buffer.asUint8List();
}

Future<Uint8List> buildStoreIconBytes({int size = 80}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );
  final s = size.toDouble();
  final center = Offset(s / 2, s / 2 - 6);

  canvas.drawCircle(
    Offset(s / 2, s / 2 + 4),
    s * 0.32,
    Paint()
      ..color = const Color(0xFFE65100).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
  );
  canvas.drawCircle(center, s * 0.40,
      Paint()..color = const Color(0xFFFF9800).withValues(alpha: 0.22));
  canvas.drawCircle(center, s * 0.30, Paint()..color = Colors.white);
  canvas.drawCircle(
    center,
    s * 0.26,
    Paint()
      ..shader = ui.Gradient.radial(
        Offset(center.dx - 3, center.dy - 3),
        s * 0.26,
        [const Color(0xFFFFB74D), const Color(0xFFE65100)],
      ),
  );
  _drawStoreIcon(canvas, center, s * 0.22, Colors.white);
  _drawAnchorTriangle(canvas, s, center, s * 0.10, s * 0.24, s * 0.30,
      const Color(0xFFE65100));

  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return pngBytes!.buffer.asUint8List();
}

void _drawAnchorTriangle(Canvas canvas, double s, Offset center, double halfW,
    double bodyBottom, double tipOffset, Color color) {
  final tipY = center.dy + tipOffset;
  final path = ui.Path()
    ..moveTo(s / 2 - halfW, center.dy + bodyBottom)
    ..lineTo(s / 2 + halfW, center.dy + bodyBottom)
    ..lineTo(s / 2, tipY)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
  canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
}

void _drawPersonIcon(Canvas canvas, Offset center, double r, Color color) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(center.dx, center.dy - r * 0.35), r * 0.30, paint);
  canvas.drawArc(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy + r * 0.30),
      width: r * 1.10,
      height: r * 0.90,
    ),
    math.pi,
    math.pi,
    true,
    paint,
  );
}

void _drawStoreIcon(Canvas canvas, Offset center, double r, Color color) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  canvas.drawPath(
    ui.Path()
      ..moveTo(center.dx - r * 0.70, center.dy - r * 0.05)
      ..lineTo(center.dx, center.dy - r * 0.65)
      ..lineTo(center.dx + r * 0.70, center.dy - r * 0.05)
      ..close(),
    paint,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
          center.dx - r * 0.48, center.dy - r * 0.08, r * 0.96, r * 0.72),
      const Radius.circular(3),
    ),
    paint,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
          center.dx - r * 0.18, center.dy + r * 0.20, r * 0.36, r * 0.44),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFFE65100),
  );
}
