import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../core/services/storage_service.dart';
import '../../core/services/overlay_service.dart';
import '../../core/services/permission_service.dart';

/// Must be overridden in main.dart with the awaited instance created
/// during app bootstrap, before [runApp] is called.
final Provider<StorageService> storageServiceProvider = Provider<StorageService>(
  (ref) => throw UnimplementedError('storageServiceProvider must be overridden in main()'),
);

final Provider<PermissionService> permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService(),
);

final Provider<OverlayService> overlayServiceProvider = Provider<OverlayService>(
  (ref) => OverlayService(ref.watch(permissionServiceProvider)),
);

/// Theme mode: 'system' | 'light' | 'dark'.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(_fromString(_storage.themeMode));

  final StorageService _storage;

  static ThemeMode _fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _storage.setThemeMode(mode.name);
  }
}

final StateNotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.watch(storageServiceProvider)),
);

/// Overlay running state, mirrored locally so the UI can react instantly.
class OverlayRunningNotifier extends StateNotifier<bool> {
  OverlayRunningNotifier(this._storage) : super(_storage.isOverlayRunning);

  final StorageService _storage;

  Future<void> setRunning(bool value) async {
    state = value;
    await _storage.setOverlayRunning(value);
  }
}

final StateNotifierProvider<OverlayRunningNotifier, bool> overlayRunningProvider =
    StateNotifierProvider<OverlayRunningNotifier, bool>(
  (ref) => OverlayRunningNotifier(ref.watch(storageServiceProvider)),
);
