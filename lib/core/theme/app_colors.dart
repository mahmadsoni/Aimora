import 'package:flutter/material.dart';

/// AIMORA brand palette.
///
/// Primary  — Electric Cyan  (#00E5FF): the crosshair itself, CTAs, active states.
/// Secondary— Deep Violet    (#7C4DFF): accents, glows, gradients.
/// Surface  — Deep Space Navy(#0B0F1A / #141B33): dark, focused, non-distracting
///            backdrop so the crosshair previews always pop.
class AppColors {
  AppColors._();

  static const Color cyan = Color(0xFF00E5FF);
  static const Color violet = Color(0xFF7C4DFF);
  static const Color navyTop = Color(0xFF0B0F1A);
  static const Color navyBottom = Color(0xFF141B33);
  static const Color white = Color(0xFFF5F8FF);

  static const Color success = Color(0xFF00E676);
  static const Color danger = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFC400);

  // Neutral surfaces
  static const Color darkSurface = Color(0xFF11162A);
  static const Color darkSurfaceVariant = Color(0xFF1B2140);
  static const Color lightSurface = Color(0xFFF7F8FC);
  static const Color lightSurfaceVariant = Color(0xFFE8EAF6);

  /// Preset crosshair colors offered in the color picker quick-swatches.
  static const List<Color> crosshairSwatches = [
    cyan,
    violet,
    success,
    danger,
    warning,
    white,
    Color(0xFFFF4081),
    Color(0xFF448AFF),
  ];

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyTop, navyBottom],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [cyan, violet],
  );
}
