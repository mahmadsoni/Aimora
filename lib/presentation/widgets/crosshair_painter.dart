import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../data/models/crosshair_model.dart';
import '../../domain/entities/crosshair_type.dart';

/// Renders any [CrosshairConfig] onto a canvas. Used both for the small
/// in-app previews (gallery, editor) and for the full-screen overlay
/// isolate — guaranteeing pixel-identical results in both places.
class CrosshairPainter extends CustomPainter {
  const CrosshairPainter({required this.config, this.animationValue = 0});

  final CrosshairConfig config;

  /// 0..1 looping value used by animated types (dynamic / cyber pulse).
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(
      size.width / 2 + config.offsetX,
      size.height / 2 + config.offsetY,
    );
    final Color color = config.color.withValues(alpha: config.opacity);
    final Paint stroke = Paint()
      ..color = color
      ..strokeWidth = config.thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Paint outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: config.opacity * 0.6)
      ..strokeWidth = config.thickness + 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void drawLine(Offset a, Offset b) {
      if (config.outline) canvas.drawLine(a, b, outlinePaint);
      canvas.drawLine(a, b, stroke);
    }

    void drawCircleStroke(double radius) {
      if (config.outline) canvas.drawCircle(center, radius, outlinePaint);
      canvas.drawCircle(center, radius, stroke);
    }

    switch (config.type) {
      case CrosshairType.dot:
        canvas.drawCircle(center, config.thickness * 1.6, fill);
        break;

      case CrosshairType.cross:
        _drawCrossTicks(drawLine, center, config.size, config.gap);
        break;

      case CrosshairType.circle:
        drawCircleStroke(config.size / 2);
        canvas.drawCircle(center, config.thickness * 1.2, fill);
        break;

      case CrosshairType.tactical:
        drawCircleStroke(config.size / 2);
        _drawCrossTicks(drawLine, center, config.size * 0.6, config.gap + config.size / 2);
        break;

      case CrosshairType.dynamic:
        // Ticks breathe outward/inward with animationValue.
        final double pulse = math.sin(animationValue * 2 * math.pi) * 6;
        _drawCrossTicks(drawLine, center, config.size + pulse, config.gap);
        canvas.drawCircle(center, config.thickness, fill);
        break;

      case CrosshairType.sniper:
        drawCircleStroke(config.size / 2);
        drawCircleStroke(config.size / 2 * 0.55);
        _drawCrossTicks(drawLine, center, config.size * 1.4, config.size / 2 * 0.55 + 4, fullLength: true);
        break;

      case CrosshairType.pro:
        _drawCrossTicks(drawLine, center, config.size, config.gap);
        canvas.drawCircle(center, config.thickness * 1.4, fill);
        drawCircleStroke(config.size * 0.75);
        break;

      case CrosshairType.minimal:
        canvas.drawCircle(center, math.max(1.5, config.thickness * 0.8), fill);
        break;

      case CrosshairType.neon:
        final Paint glow = Paint()
          ..color = color.withValues(alpha: config.opacity * 0.55)
          ..strokeWidth = config.thickness + 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        void drawGlowLine(Offset a, Offset b) {
          canvas.drawLine(a, b, glow);
          canvas.drawLine(a, b, stroke);
        }

        _drawCrossTicks(drawGlowLine, center, config.size, config.gap);
        canvas.drawCircle(center, config.thickness + 3, glow);
        canvas.drawCircle(center, config.thickness * 1.2, fill);
        break;

      case CrosshairType.cyber:
        final double rot = animationValue * 2 * math.pi;
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(rot);
        canvas.translate(-center.dx, -center.dy);
        _drawCornerBrackets(drawLine, center, config.size, config.thickness);
        canvas.restore();
        canvas.drawCircle(center, config.thickness, fill);
        break;
    }
  }

  void _drawCrossTicks(
    void Function(Offset, Offset) drawLine,
    Offset center,
    double length,
    double gap, {
    bool fullLength = false,
  }) {
    final double half = fullLength ? length : length / 2;
    // top
    drawLine(Offset(center.dx, center.dy - gap), Offset(center.dx, center.dy - gap - half));
    // bottom
    drawLine(Offset(center.dx, center.dy + gap), Offset(center.dx, center.dy + gap + half));
    // left
    drawLine(Offset(center.dx - gap, center.dy), Offset(center.dx - gap - half, center.dy));
    // right
    drawLine(Offset(center.dx + gap, center.dy), Offset(center.dx + gap + half, center.dy));
  }

  void _drawCornerBrackets(
    void Function(Offset, Offset) drawLine,
    Offset center,
    double size,
    double thickness,
  ) {
    final double r = size / 2;
    final double armLen = size * 0.35;
    final List<Offset> corners = [
      Offset(center.dx - r, center.dy - r),
      Offset(center.dx + r, center.dy - r),
      Offset(center.dx - r, center.dy + r),
      Offset(center.dx + r, center.dy + r),
    ];
    for (final Offset c in corners) {
      final double dx = c.dx < center.dx ? 1 : -1;
      final double dy = c.dy < center.dy ? 1 : -1;
      drawLine(c, Offset(c.dx + armLen * dx, c.dy));
      drawLine(c, Offset(c.dx, c.dy + armLen * dy));
    }
  }

  @override
  bool shouldRepaint(covariant CrosshairPainter oldDelegate) {
    return oldDelegate.config != config || oldDelegate.animationValue != animationValue;
  }
}
