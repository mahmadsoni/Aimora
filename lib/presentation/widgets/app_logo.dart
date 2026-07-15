import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Vector-drawn AIMORA logo mark (ring + center dot + four ticks), used
/// on the splash screen and onboarding so it scales crisply at any size
/// without shipping a raster asset.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 120, this.animate = false});

  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final Widget mark = CustomPaint(
      size: Size(size, size),
      painter: _LogoPainter(),
    );
    if (!animate) return mark;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        return Transform.scale(scale: t.clamp(0, 1.2), child: Opacity(opacity: t.clamp(0, 1), child: child));
      },
      child: mark,
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width * 0.32;

    final Paint ring = Paint()
      ..color = AppColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;

    final Paint glow = Paint()
      ..color = AppColors.violet.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, r, glow);
    canvas.drawCircle(center, r, ring);

    final Paint dot = Paint()..color = AppColors.white;
    canvas.drawCircle(center, size.width * 0.045, dot);

    final double gap = size.width * 0.08;
    final double tick = size.width * 0.17;
    final Paint tickPaint = Paint()
      ..color = AppColors.cyan
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(center.dx, center.dy - r - gap), Offset(center.dx, center.dy - r - gap - tick), tickPaint);
    canvas.drawLine(Offset(center.dx, center.dy + r + gap), Offset(center.dx, center.dy + r + gap + tick), tickPaint);
    canvas.drawLine(Offset(center.dx - r - gap, center.dy), Offset(center.dx - r - gap - tick, center.dy), tickPaint);
    canvas.drawLine(Offset(center.dx + r + gap, center.dy), Offset(center.dx + r + gap + tick, center.dy), tickPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
