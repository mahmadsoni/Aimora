import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'permission_service.dart';

/// Starts, stops and live-updates the Android system overlay that renders
/// the crosshair on top of every other app (games included).
///
/// The overlay runs in its own Flutter engine/isolate (entry point:
/// `overlayMain` in lib/overlay/overlay_main.dart). Configuration changes
/// made in the main app are pushed to it via [FlutterOverlayWindow.shareData],
/// which the overlay isolate listens to in real time — so moving a slider
/// updates the crosshair on screen instantly, with no restart required.
class OverlayService {
  OverlayService(this._permissionService);

  final PermissionService _permissionService;

  Future<bool> get isActive async => await FlutterOverlayWindow.isActive();

  /// Starts the overlay. Returns false if permission is missing.
  Future<bool> start() async {
    final bool granted = await _permissionService.hasOverlayPermission();
    if (!granted) return false;

    if (await isActive) return true;

    await FlutterOverlayWindow.showOverlay(
      height: WindowSize.matchParent,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.center,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
      overlayTitle: 'AIMORA',
      overlayContent: 'Crosshair overlay is active',
      enableDrag: false,
    );
    return true;
  }

  Future<void> stop() async {
    if (await isActive) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  /// Pushes an updated JSON-encoded crosshair configuration to the live
  /// overlay isolate so the on-screen reticle updates immediately.
  Future<void> pushConfig(Map<String, dynamic> configJson) async {
    if (await isActive) {
      await FlutterOverlayWindow.shareData(configJson);
    }
  }
}
