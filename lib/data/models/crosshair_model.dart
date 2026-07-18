import 'package:flutter/material.dart';

import '../../domain/entities/crosshair_type.dart';

/// Complete visual configuration of a crosshair. This is the single
/// source of truth consumed by both the in-app preview and the
/// system overlay isolate.
@immutable
class CrosshairConfig {
  const CrosshairConfig({
    required this.type,
    required this.colorValue,
    required this.size,
    required this.thickness,
    required this.gap,
    required this.opacity,
    required this.outline,
    this.offsetX = 0,
    this.offsetY = 0,
  });

  final CrosshairType type;
  final int colorValue; // ARGB int, safe to store in prefs/JSON
  final double size;
  final double thickness;
  final double gap;
  final double opacity;
  final bool outline;

  /// Horizontal/vertical offset (in logical pixels) from dead-center,
  /// so the crosshair can be nudged to line up with a game's own
  /// off-center aim point. Positive x moves right, positive y moves down.
  final double offsetX;
  final double offsetY;

  Color get color => Color(colorValue);

  factory CrosshairConfig.defaults() => const CrosshairConfig(
        type: CrosshairType.cross,
        colorValue: 0xFF00E5FF, // AppColors.cyan
        size: 40,
        thickness: 3,
        gap: 8,
        opacity: 1.0,
        outline: true,
        offsetX: 0,
        offsetY: 0,
      );

  CrosshairConfig copyWith({
    CrosshairType? type,
    int? colorValue,
    double? size,
    double? thickness,
    double? gap,
    double? opacity,
    bool? outline,
    double? offsetX,
    double? offsetY,
  }) {
    return CrosshairConfig(
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      size: size ?? this.size,
      thickness: thickness ?? this.thickness,
      gap: gap ?? this.gap,
      opacity: opacity ?? this.opacity,
      outline: outline ?? this.outline,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'color': colorValue,
        'size': size,
        'thickness': thickness,
        'gap': gap,
        'opacity': opacity,
        'outline': outline,
        'offsetX': offsetX,
        'offsetY': offsetY,
      };

  factory CrosshairConfig.fromJson(Map<String, dynamic> json) {
    return CrosshairConfig(
      type: CrosshairType.fromName(json['type'] as String? ?? 'cross'),
      colorValue: json['color'] as int? ?? 0xFF00E5FF,
      size: (json['size'] as num?)?.toDouble() ?? 40,
      thickness: (json['thickness'] as num?)?.toDouble() ?? 3,
      gap: (json['gap'] as num?)?.toDouble() ?? 8,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      outline: json['outline'] as bool? ?? true,
      offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0,
      offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrosshairConfig &&
        other.type == type &&
        other.colorValue == colorValue &&
        other.size == size &&
        other.thickness == thickness &&
        other.gap == gap &&
        other.opacity == opacity &&
        other.outline == outline &&
        other.offsetX == offsetX &&
        other.offsetY == offsetY;
  }

  @override
  int get hashCode =>
      Object.hash(type, colorValue, size, thickness, gap, opacity, outline, offsetX, offsetY);
}
