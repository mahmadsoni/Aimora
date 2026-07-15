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
  });

  final CrosshairType type;
  final int colorValue; // ARGB int, safe to store in prefs/JSON
  final double size;
  final double thickness;
  final double gap;
  final double opacity;
  final bool outline;

  Color get color => Color(colorValue);

  factory CrosshairConfig.defaults() => const CrosshairConfig(
        type: CrosshairType.cross,
        colorValue: 0xFF00E5FF, // AppColors.cyan
        size: 40,
        thickness: 3,
        gap: 8,
        opacity: 1.0,
        outline: true,
      );

  CrosshairConfig copyWith({
    CrosshairType? type,
    int? colorValue,
    double? size,
    double? thickness,
    double? gap,
    double? opacity,
    bool? outline,
  }) {
    return CrosshairConfig(
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      size: size ?? this.size,
      thickness: thickness ?? this.thickness,
      gap: gap ?? this.gap,
      opacity: opacity ?? this.opacity,
      outline: outline ?? this.outline,
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
        other.outline == outline;
  }

  @override
  int get hashCode => Object.hash(type, colorValue, size, thickness, gap, opacity, outline);
}
