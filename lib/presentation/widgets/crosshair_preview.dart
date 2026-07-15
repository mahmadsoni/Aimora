import 'package:flutter/material.dart';

import '../../data/models/crosshair_model.dart';
import '../../domain/entities/crosshair_type.dart';
import 'crosshair_painter.dart';

/// A self-animating preview box for a [CrosshairConfig]. Runs a looping
/// animation clock so the `dynamic` and `cyber` types visibly pulse/rotate
/// even inside static gallery grids.
class CrosshairPreview extends StatefulWidget {
  const CrosshairPreview({
    super.key,
    required this.config,
    this.size = 96,
    this.backgroundColor,
  });

  final CrosshairConfig config;
  final double size;
  final Color? backgroundColor;

  @override
  State<CrosshairPreview> createState() => _CrosshairPreviewState();
}

class _CrosshairPreviewState extends State<CrosshairPreview> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _needsAnimation =>
      widget.config.type == CrosshairType.dynamic || widget.config.type == CrosshairType.cyber;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget box = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
    );

    if (!_needsAnimation) {
      return Stack(
        alignment: Alignment.center,
        children: [
          box,
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: CrosshairPainter(config: widget.config),
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        box,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CrosshairPainter(config: widget.config, animationValue: _controller.value),
            );
          },
        ),
      ],
    );
  }
}
