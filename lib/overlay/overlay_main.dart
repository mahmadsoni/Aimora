import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../data/models/crosshair_model.dart';
import '../presentation/widgets/crosshair_painter.dart';

/// Entry point for the secondary Flutter engine that AIMORA's system
/// overlay runs in. Started by `flutter_overlay_window` when the user
/// taps "Start Overlay" (see [OverlayService.start]).
///
/// This isolate is intentionally tiny: a single full-screen, click-through,
/// transparent widget that paints the current [CrosshairConfig] dead
/// center. It listens to [FlutterOverlayWindow.overlayListener] so any
/// slider change made in the main app is reflected instantly without
/// restarting the overlay.
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();

  // Safety net: if anything ever throws while building the overlay's
  // widget tree, show nothing instead of Flutter's default full-screen
  // red error box. The overlay window sits on top of every other app,
  // so an opaque error screen here would visually block the whole
  // device — this keeps a failure invisible and harmless instead.
  ErrorWidget.builder = (FlutterErrorDetails details) => const SizedBox.shrink();

  runApp(const _OverlayApp());
}

class _OverlayApp extends StatefulWidget {
  const _OverlayApp();

  @override
  State<_OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<_OverlayApp> with SingleTickerProviderStateMixin {
  CrosshairConfig _config = CrosshairConfig.defaults();
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is Map) {
        try {
          setState(() {
            _config = CrosshairConfig.fromJson(Map<String, dynamic>.from(event));
          });
        } catch (_) {
          // Ignore malformed payloads — keep showing the last good config.
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Deliberately minimal: Directionality + Material (not MaterialApp /
    // Scaffold / AppBar) so this tiny overlay engine never needs
    // MaterialLocalizations, Navigator, or any other app-level
    // machinery that could fail to attach during the overlay window's
    // own lifecycle.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        type: MaterialType.transparency,
        child: IgnorePointer(
          child: SizedBox.expand(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: CrosshairPainter(config: _config, animationValue: _animController.value),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
