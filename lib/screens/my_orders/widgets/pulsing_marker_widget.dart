import 'package:flutter/material.dart';

/// Wraps a child widget (typically a rider icon) with concentric pulsing
/// rings that expand and fade — giving a "live tracking" indicator effect.
class PulsingMarkerWidget extends StatefulWidget {
  final Widget child;
  final double size;
  final Color pulseColor;

  const PulsingMarkerWidget({
    super.key,
    required this.child,
    this.size = 70,
    required this.pulseColor,
  });

  @override
  State<PulsingMarkerWidget> createState() => _PulsingMarkerWidgetState();
}

class _PulsingMarkerWidgetState extends State<PulsingMarkerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleOuter;
  late final Animation<double> _opacityOuter;
  late final Animation<double> _scaleInner;
  late final Animation<double> _opacityInner;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _scaleOuter = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityOuter = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleInner = Tween<double>(begin: 0.45, end: 0.75).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
      ),
    );
    _opacityInner = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              _buildRing(_scaleOuter.value, _opacityOuter.value),
              // Inner pulse ring (staggered)
              _buildRing(_scaleInner.value, _opacityInner.value),
              // Actual rider icon
              widget.child,
            ],
          );
        },
      ),
    );
  }

  Widget _buildRing(double scale, double opacity) {
    final ringSize = widget.size * scale;
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        width: ringSize,
        height: ringSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.pulseColor,
            width: 2.0,
          ),
          color: widget.pulseColor.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
