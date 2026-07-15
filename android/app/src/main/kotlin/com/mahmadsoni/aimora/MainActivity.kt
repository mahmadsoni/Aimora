package com.mahmadsoni.aimora

import io.flutter.embedding.android.FlutterActivity

/**
 * Single activity host for the AIMORA Flutter engine.
 *
 * The overlay window itself is rendered by a separate Flutter engine
 * (see lib/overlay/overlay_main.dart) that is started and controlled by
 * the `flutter_overlay_window` plugin, so this Activity stays minimal.
 */
class MainActivity : FlutterActivity()
