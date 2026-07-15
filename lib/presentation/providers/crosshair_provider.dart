import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/crosshair_model.dart';
import '../../data/models/preset_model.dart';
import '../../domain/entities/crosshair_type.dart';
import 'settings_provider.dart';

/// Currently edited / overlaid crosshair configuration. Every change here
/// is persisted immediately and, if the overlay is active, pushed live to
/// the on-screen reticle.
class ActiveCrosshairNotifier extends StateNotifier<CrosshairConfig> {
  ActiveCrosshairNotifier(this._ref) : super(_ref.read(storageServiceProvider).getOverlayConfig());

  final Ref _ref;

  Future<void> update(CrosshairConfig Function(CrosshairConfig current) updater) async {
    final CrosshairConfig next = updater(state);
    state = next;
    await _ref.read(storageServiceProvider).saveOverlayConfig(next);
    await _ref.read(overlayServiceProvider).pushConfig(next.toJson());
  }

  Future<void> setType(CrosshairType type) => update((c) => c.copyWith(type: type));
  Future<void> setColor(int colorValue) => update((c) => c.copyWith(colorValue: colorValue));
  Future<void> setSize(double size) => update((c) => c.copyWith(size: size));
  Future<void> setThickness(double thickness) => update((c) => c.copyWith(thickness: thickness));
  Future<void> setGap(double gap) => update((c) => c.copyWith(gap: gap));
  Future<void> setOpacity(double opacity) => update((c) => c.copyWith(opacity: opacity));
  Future<void> setOutline(bool outline) => update((c) => c.copyWith(outline: outline));

  Future<void> applyConfig(CrosshairConfig config) => update((_) => config);

  Future<void> resetToDefaults() => update((_) => CrosshairConfig.defaults());
}

final StateNotifierProvider<ActiveCrosshairNotifier, CrosshairConfig> activeCrosshairProvider =
    StateNotifierProvider<ActiveCrosshairNotifier, CrosshairConfig>(
  (ref) => ActiveCrosshairNotifier(ref),
);

/// Favorite crosshair *types* (quick shortlist in the gallery).
class FavoritesNotifier extends StateNotifier<Set<CrosshairType>> {
  FavoritesNotifier(this._ref)
      : super(_ref.read(storageServiceProvider).getFavoriteTypeNames().map(CrosshairType.fromName).toSet());

  final Ref _ref;

  Future<void> toggle(CrosshairType type) async {
    final Set<CrosshairType> next = {...state};
    if (next.contains(type)) {
      next.remove(type);
    } else {
      next.add(type);
    }
    state = next;
    await _ref.read(storageServiceProvider).saveFavoriteTypeNames(next.map((e) => e.name).toSet());
  }

  bool isFavorite(CrosshairType type) => state.contains(type);
}

final StateNotifierProvider<FavoritesNotifier, Set<CrosshairType>> favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<CrosshairType>>(
  (ref) => FavoritesNotifier(ref),
);

/// Saved presets — full named [CrosshairConfig] snapshots.
class PresetsNotifier extends StateNotifier<List<PresetModel>> {
  PresetsNotifier(this._ref) : super(_ref.read(storageServiceProvider).getPresets());

  final Ref _ref;

  Future<void> add(String name, CrosshairConfig config) async {
    final PresetModel preset = PresetModel.create(name: name, config: config);
    state = [...state, preset];
    await _ref.read(storageServiceProvider).savePresets(state);
  }

  Future<void> remove(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _ref.read(storageServiceProvider).savePresets(state);
  }

  Future<void> toggleFavorite(String id) async {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(isFavorite: !p.isFavorite) else p,
    ];
    await _ref.read(storageServiceProvider).savePresets(state);
  }
}

final StateNotifierProvider<PresetsNotifier, List<PresetModel>> presetsProvider =
    StateNotifierProvider<PresetsNotifier, List<PresetModel>>(
  (ref) => PresetsNotifier(ref),
);
