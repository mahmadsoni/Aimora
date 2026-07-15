import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// Wraps the Android "draw over other apps" permission flow.
///
/// This is a special permission that cannot be requested through a
/// standard runtime dialog — the OS forces the user through the
/// Settings app, so we simply open that screen and let the user
/// return to AIMORA afterwards.
class PermissionService {
  Future<bool> hasOverlayPermission() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  /// Opens Android's "Display over other apps" settings screen for AIMORA.
  /// Returns true once the system reports permission granted (the plugin
  /// re-checks after the settings screen is dismissed).
  Future<bool> requestOverlayPermission() async {
    final bool? granted = await FlutterOverlayWindow.requestPermission();
    return granted ?? await hasOverlayPermission();
  }
}
