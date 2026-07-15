import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/crosshair_model.dart';
import '../../data/models/profile_model.dart';
import 'crosshair_provider.dart';
import 'settings_provider.dart';

class ProfilesState {
  const ProfilesState({required this.profiles, required this.activeId});

  final List<ProfileModel> profiles;
  final String? activeId;

  ProfileModel? get active {
    for (final ProfileModel p in profiles) {
      if (p.id == activeId) return p;
    }
    return null;
  }

  ProfilesState copyWith({List<ProfileModel>? profiles, String? activeId}) {
    return ProfilesState(profiles: profiles ?? this.profiles, activeId: activeId ?? this.activeId);
  }
}

/// Manages the list of gaming profiles (e.g. "PUBG", "Free Fire") — each
/// with its own independent [CrosshairConfig] — and which one is active.
class ProfilesNotifier extends StateNotifier<ProfilesState> {
  ProfilesNotifier(this._ref)
      : super(ProfilesState(
          profiles: _ref.read(storageServiceProvider).getProfiles(),
          activeId: _ref.read(storageServiceProvider).activeProfileId,
        )) {
    if (state.profiles.isEmpty) {
      _seedDefaultProfile();
    }
  }

  final Ref _ref;

  Future<void> _seedDefaultProfile() async {
    final ProfileModel def = ProfileModel.create(name: 'Default', config: CrosshairConfig.defaults());
    state = ProfilesState(profiles: [def], activeId: def.id);
    await _persist();
  }

  Future<void> _persist() async {
    await _ref.read(storageServiceProvider).saveProfiles(state.profiles);
    if (state.activeId != null) {
      await _ref.read(storageServiceProvider).setActiveProfileId(state.activeId!);
    }
  }

  Future<void> create(String name, {int? avatarColorValue}) async {
    final ProfileModel profile = ProfileModel.create(
      name: name,
      avatarColorValue: avatarColorValue,
      config: _ref.read(activeCrosshairProvider),
    );
    state = state.copyWith(profiles: [...state.profiles, profile]);
    await _persist();
  }

  Future<void> delete(String id) async {
    if (state.profiles.length <= 1) return; // always keep at least one profile
    final List<ProfileModel> next = state.profiles.where((p) => p.id != id).toList();
    final String? nextActive = state.activeId == id ? next.first.id : state.activeId;
    state = state.copyWith(profiles: next, activeId: nextActive);
    await _persist();
    if (nextActive != null && state.activeId == nextActive) {
      final ProfileModel? p = state.active;
      if (p != null) {
        await _ref.read(activeCrosshairProvider.notifier).applyConfig(p.config);
      }
    }
  }

  Future<void> rename(String id, String newName) async {
    state = state.copyWith(
      profiles: [
        for (final p in state.profiles)
          if (p.id == id) p.copyWith(name: newName) else p,
      ],
    );
    await _persist();
  }

  /// Switches the active profile and loads its saved crosshair config into
  /// the live editor/overlay.
  Future<void> switchTo(String id) async {
    state = state.copyWith(activeId: id);
    await _persist();
    final ProfileModel? p = state.active;
    if (p != null) {
      await _ref.read(activeCrosshairProvider.notifier).applyConfig(p.config);
    }
  }

  /// Persists the current live crosshair config back into the active
  /// profile (call after the user finishes editing).
  Future<void> syncActiveProfileConfig() async {
    final String? id = state.activeId;
    if (id == null) return;
    final CrosshairConfig current = _ref.read(activeCrosshairProvider);
    state = state.copyWith(
      profiles: [
        for (final p in state.profiles)
          if (p.id == id) p.copyWith(config: current) else p,
      ],
    );
    await _persist();
  }
}

final StateNotifierProvider<ProfilesNotifier, ProfilesState> profilesProvider =
    StateNotifierProvider<ProfilesNotifier, ProfilesState>(
  (ref) => ProfilesNotifier(ref),
);
