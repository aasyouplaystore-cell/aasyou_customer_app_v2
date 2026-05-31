import 'package:flutter/material.dart';

/// Connector line that animates fill for completed segments
class AnimatedPulsingLine extends StatefulWidget {
  final double height;
  final double width;
  final bool filled;
  final Color activeColor;

  const AnimatedPulsingLine({
    super.key,
    required this.height,
    required this.width,
    required this.filled,
    required this.activeColor,
  });

  @override
  State<AnimatedPulsingLine> createState() => _AnimatedPulsingLineState();
}

class _AnimatedPulsingLineState extends State<AnimatedPulsingLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fill;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fill = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.filled) _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedPulsingLine old) {
    super.didUpdateWidget(old);
    if (widget.filled && !old.filled) _ctrl.forward();
    if (!widget.filled && old.filled) _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Background (unfilled) line
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // Animated fill overlay
          AnimatedBuilder(
            animation: _fill,
            builder: (_, __) => Container(
              width: widget.width,
              height: widget.height * _fill.value,
              decoration: BoxDecoration(
                color: widget.activeColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}