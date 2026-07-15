import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';
import '../widgets/crosshair_preview.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _createProfile(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController();
    final String? name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('profile_new'.tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'profile_name'.tr()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('profile_create'.tr()),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(profilesProvider.notifier).create(name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _createProfile(context, ref),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: state.profiles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final profile = state.profiles[i];
          final bool active = profile.id == state.activeId;
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: active ? const BorderSide(color: AppColors.cyan, width: 2) : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: profile.avatarColor,
                child: CrosshairPreview(
                  config: profile.config,
                  size: 40,
                  backgroundColor: Colors.transparent,
                ),
              ),
              title: Text(profile.name),
              subtitle: Text(active ? 'profile_active'.tr() : profile.config.type.labelKey.tr()),
              trailing: active
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
                  : TextButton(
                      onPressed: () => ref.read(profilesProvider.notifier).switchTo(profile.id),
                      child: Text('profile_switch'.tr()),
                    ),
              onLongPress: state.profiles.length > 1
                  ? () => ref.read(profilesProvider.notifier).delete(profile.id)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
