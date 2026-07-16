import 'package:flutter/material.dart';

/// Converts a [Color] to a 32-bit ARGB integer using the modern
/// component accessors (`.a`, `.r`, `.g`, `.b`, each 0.0–1.0) instead of
/// the deprecated `Color.value` getter, so this keeps working cleanly
/// across Flutter's wide-gamut Color API changes.
extension ColorArgbInt on Color {
  int toArgbInt() {
    int channel(double v) => (v.clamp(0.0, 1.0) * 255).round();
    return (channel(a) << 24) | (channel(r) << 16) | (channel(g) << 8) | channel(b);
  }
}
