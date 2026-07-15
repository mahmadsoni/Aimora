import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'crosshair_model.dart';

const Uuid _uuid = Uuid();

/// A user profile groups an independent crosshair configuration, letting
/// a player keep e.g. "Mobile Legends" and "PUBG" tuned differently and
/// switch between them in one tap.
@immutable
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.avatarColorValue,
    required this.config,
  });

  final String id;
  final String name;
  final int avatarColorValue;
  final CrosshairConfig config;

  Color get avatarColor => Color(avatarColorValue);

  factory ProfileModel.create({required String name, int? avatarColorValue, CrosshairConfig? config}) {
    return ProfileModel(
      id: _uuid.v4(),
      name: name,
      avatarColorValue: avatarColorValue ?? 0xFF00E5FF,
      config: config ?? CrosshairConfig.defaults(),
    );
  }

  ProfileModel copyWith({String? name, int? avatarColorValue, CrosshairConfig? config}) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      config: config ?? this.config,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarColor': avatarColorValue,
        'config': config.toJson(),
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarColorValue: json['avatarColor'] as int? ?? 0xFF00E5FF,
      config: CrosshairConfig.fromJson(json['config'] as Map<String, dynamic>),
    );
  }
}
