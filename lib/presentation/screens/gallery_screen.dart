import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/crosshair_model.dart';
import '../../domain/entities/crosshair_type.dart';
import '../providers/crosshair_provider.dart';
import '../widgets/crosshair_preview.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('gallery'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'select_type'.tr()),
            Tab(text: 'favorites'.tr()),
            Tab(text: 'presets'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TypeGrid(),
          _FavoritesList(),
          _PresetsList(),
        ],
      ),
    );
  }
}

class _TypeGrid extends ConsumerWidget {
  const _TypeGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CrosshairConfig active = ref.watch(activeCrosshairProvider);
    final favorites = ref.watch(favoritesProvider);
    final favNotifier = ref.read(favoritesProvider.notifier);

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.92,
      ),
      itemCount: CrosshairType.values.length,
      itemBuilder: (context, i) {
        final CrosshairType type = CrosshairType.values[i];
        final bool selected = active.type == type;
        final bool fav = favorites.contains(type);
        final CrosshairConfig previewConfig = active.copyWith(type: type);

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => ref.read(activeCrosshairProvider.notifier).setType(type),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardTheme.color,
              border: selected ? Border.all(color: AppColors.cyan, width: 2) : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    icon: Icon(
                      fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: fav ? AppColors.danger : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => favNotifier.toggle(type),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CrosshairPreview(config: previewConfig, size: 84),
                    const SizedBox(height: 12),
                    Text(type.labelKey.tr(), style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FavoritesList extends ConsumerWidget {
  const _FavoritesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider).toList();
    final CrosshairConfig active = ref.watch(activeCrosshairProvider);

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('no_favorites'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final CrosshairType type = favorites[i];
        return Card(
          child: ListTile(
            leading: CrosshairPreview(config: active.copyWith(type: type), size: 52),
            title: Text(type.labelKey.tr()),
            trailing: IconButton(
              icon: const Icon(Icons.favorite_rounded, color: AppColors.danger),
              onPressed: () => ref.read(favoritesProvider.notifier).toggle(type),
            ),
            onTap: () => ref.read(activeCrosshairProvider.notifier).setType(type),
          ),
        );
      },
    );
  }
}

class _PresetsList extends ConsumerWidget {
  const _PresetsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(presetsProvider);

    if (presets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('no_presets'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: presets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final preset = presets[i];
        return Card(
          child: ListTile(
            leading: CrosshairPreview(config: preset.config, size: 52),
            title: Text(preset.name),
            subtitle: Text(preset.config.type.labelKey.tr()),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              onPressed: () => ref.read(presetsProvider.notifier).remove(preset.id),
            ),
            onTap: () => ref.read(activeCrosshairProvider.notifier).applyConfig(preset.config),
          ),
        );
      },
    );
  }
}
