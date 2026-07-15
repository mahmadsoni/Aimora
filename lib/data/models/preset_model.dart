import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'crosshair_model.dart';

const Uuid _uuid = Uuid();

/// A named, user-saved [CrosshairConfig] that can be recalled instantly
/// from the Presets tab (e.g. "Warzone Sniper", "Valorant Dot").
@immutable
class PresetModel {
  const PresetModel({
    required this.id,
    required this.name,
    required this.config,
    required this.isFavorite,
    required this.createdAt,
  });

  final String id;
  final String name;
  final CrosshairConfig config;
  final bool isFavorite;
  final DateTime createdAt;

  factory PresetModel.create({required String name, required CrosshairConfig config}) {
    return PresetModel(
      id: _uuid.v4(),
      name: name,
      config: config,
      isFavorite: false,
      createdAt: DateTime.now(),
    );
  }

  PresetModel copyWith({String? name, CrosshairConfig? config, bool? isFavorite}) {
    return PresetModel(
      id: id,
      name: name ?? this.name,
      config: config ?? this.config,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'config': config.toJson(),
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PresetModel.fromJson(Map<String, dynamic> json) {
    return PresetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      config: CrosshairConfig.fromJson(json['config'] as Map<String, dynamic>),
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
