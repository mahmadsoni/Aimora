import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/color_utils.dart';
import '../providers/crosshair_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/crosshair_preview.dart';

class OverlayControlScreen extends ConsumerStatefulWidget {
  const OverlayControlScreen({super.key});

  @override
  ConsumerState<OverlayControlScreen> createState() => _OverlayControlScreenState();
}

class _OverlayControlScreenState extends ConsumerState<OverlayControlScreen> {
  bool _busy = false;
  double _moveStep = 6;

  Future<void> _toggleOverlay() async {
    setState(() => _busy = true);
    final overlay = ref.read(overlayServiceProvider);
    final running = ref.read(overlayRunningProvider);
    try {
      if (running) {
        await overlay.stop();
        await ref.read(overlayRunningProvider.notifier).setRunning(false);
      } else {
        final bool started = await overlay.start();
        if (started) {
          await ref.read(overlayRunningProvider.notifier).setRunning(true);
          await overlay.pushConfig(ref.read(activeCrosshairProvider).toJson());
        } else if (mounted) {
          _showPermissionSheet();
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showPermissionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.layers_rounded, size: 48, color: AppColors.cyan),
            const SizedBox(height: 16),
            Text('permission_required_title'.tr(), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('permission_required_desc'.tr(), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(permissionServiceProvider).requestOverlayPermission();
                },
                child: Text('permission_open_settings'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickColor(int currentValue) async {
    final Color picked = await showColorPickerDialog(
      context,
      Color(currentValue),
      title: Text('color'.tr(), style: Theme.of(context).textTheme.titleMedium),
      pickersEnabled: const {ColorPickerType.wheel: true, ColorPickerType.primary: true},
      enableShadesSelection: true,
    );
    await ref.read(activeCrosshairProvider.notifier).setColor(picked.toArgbInt());
  }

  Future<void> _saveAsPreset() async {
    final TextEditingController controller = TextEditingController();
    final String? name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('save_preset'.tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'preset_name'.tr()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(presetsProvider.notifier).add(name, ref.read(activeCrosshairProvider));
      await ref.read(profilesProvider.notifier).syncActiveProfileConfig();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'save'.tr()}: $name')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(activeCrosshairProvider);
    final notifier = ref.read(activeCrosshairProvider.notifier);
    final bool running = ref.watch(overlayRunningProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('crosshair_control'.tr()),
        actions: [
          IconButton(
            tooltip: 'reset'.tr(),
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () => notifier.resetToDefaults(),
          ),
          IconButton(
            tooltip: 'save_preset'.tr(),
            icon: const Icon(Icons.bookmark_add_rounded),
            onPressed: _saveAsPreset,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Live preview card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 220,
              decoration: const BoxDecoration(gradient: AppColors.brandGradient),
              child: Center(child: CrosshairPreview(config: config, size: 150, backgroundColor: Colors.transparent)),
            ),
          ),
          const SizedBox(height: 20),

          // Start/Stop button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _toggleOverlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: running ? AppColors.danger : AppColors.cyan,
                foregroundColor: running ? Colors.white : Colors.black,
              ),
              icon: Icon(running ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded),
              label: Text(running ? 'stop_overlay'.tr() : 'start_overlay'.tr()),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 10, color: running ? AppColors.success : Colors.grey),
              const SizedBox(width: 8),
              Text(running ? 'overlay_active'.tr() : 'overlay_inactive'.tr()),
            ],
          ),
          const SizedBox(height: 28),

          // Position (D-pad)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel('position'.tr()),
              TextButton.icon(
                onPressed: () => notifier.resetPosition(),
                icon: const Icon(Icons.center_focus_strong_rounded, size: 18),
                label: Text('reset_position'.tr()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DPad(
                onMove: (dx, dy) => notifier.nudgePosition(dx * _moveStep, dy * _moveStep),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel('move_speed'.tr()),
                        Text(_moveStep.toStringAsFixed(0), style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                    Slider(
                      value: _moveStep,
                      min: 1,
                      max: 30,
                      onChanged: (v) => setState(() => _moveStep = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Color
          _SectionLabel('color'.tr()),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _pickColor(config.colorValue),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: config.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                ),
                const SizedBox(width: 16),
                ...AppColors.crosshairSwatches.take(6).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => notifier.setColor(c.toArgbInt()),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SliderRow(
            label: 'size'.tr(),
            value: config.size,
            min: AppConstants.minCrosshairSize,
            max: AppConstants.maxCrosshairSize,
            onChanged: notifier.setSize,
          ),
          _SliderRow(
            label: 'thickness'.tr(),
            value: config.thickness,
            min: AppConstants.minThickness,
            max: AppConstants.maxThickness,
            onChanged: notifier.setThickness,
          ),
          _SliderRow(
            label: 'gap'.tr(),
            value: config.gap,
            min: AppConstants.minGap,
            max: AppConstants.maxGap,
            onChanged: notifier.setGap,
          ),
          _SliderRow(
            label: 'opacity'.tr(),
            value: config.opacity,
            min: AppConstants.minOpacity,
            max: AppConstants.maxOpacity,
            onChanged: notifier.setOpacity,
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('outline'.tr()),
            value: config.outline,
            onChanged: notifier.setOutline,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey));
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel(label),
            Text(value.toStringAsFixed(1), style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

/// Compact directional pad used to nudge the crosshair's on-screen
/// position (up/down/left/right), so it can be lined up with a game's
/// own off-center aim point. Each tap moves by the current "speed"
/// step; holding a button repeats the move for fast, continuous nudging.
class _DPad extends StatelessWidget {
  const _DPad({required this.onMove});

  final void Function(double dx, double dy) onMove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      height: 156,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dpadButton(icon: Icons.keyboard_arrow_up_rounded, onTap: () => onMove(0, -1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dpadButton(icon: Icons.keyboard_arrow_left_rounded, onTap: () => onMove(-1, 0)),
              const SizedBox(width: 48, height: 48),
              _dpadButton(icon: Icons.keyboard_arrow_right_rounded, onTap: () => onMove(1, 0)),
            ],
          ),
          _dpadButton(icon: Icons.keyboard_arrow_down_rounded, onTap: () => onMove(0, 1)),
        ],
      ),
    );
  }

  Widget _dpadButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: AppColors.darkSurfaceVariant,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.cyan),
        ),
      ),
    );
  }
}
