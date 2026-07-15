import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/crosshair_model.dart';
import '../../data/models/preset_model.dart';
import '../../data/models/profile_model.dart';
import '../constants/app_constants.dart';

/// Single, offline-first persistence gateway for the whole app.
///
/// AIMORA never talks to a network for its core functionality — every
/// profile, preset, favorite and setting lives in [SharedPreferences] as
/// JSON, so the app works fully offline and starts instantly.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ---- Onboarding -------------------------------------------------
  bool get isOnboardingDone => _prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool value) => _prefs.setBool(AppConstants.keyOnboardingDone, value);

  // ---- Theme / Locale ----------------------------------------------
  String? get themeMode => _prefs.getString(AppConstants.keyThemeMode);
  Future<void> setThemeMode(String mode) => _prefs.setString(AppConstants.keyThemeMode, mode);

  String? get localeCode => _prefs.getString(AppConstants.keyLocale);
  Future<void> setLocaleCode(String code) => _prefs.setString(AppConstants.keyLocale, code);

  // ---- Overlay live config (read by the overlay isolate) -----------
  CrosshairConfig getOverlayConfig() {
    final String? raw = _prefs.getString(AppConstants.keyOverlayConfig);
    if (raw == null) return CrosshairConfig.defaults();
    try {
      return CrosshairConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return CrosshairConfig.defaults();
    }
  }

  Future<void> saveOverlayConfig(CrosshairConfig config) {
    return _prefs.setString(AppConstants.keyOverlayConfig, jsonEncode(config.toJson()));
  }

  bool get isOverlayRunning => _prefs.getBool(AppConstants.keyOverlayRunning) ?? false;
  Future<void> setOverlayRunning(bool value) => _prefs.setBool(AppConstants.keyOverlayRunning, value);

  // ---- Presets -------------------------------------------------------
  List<PresetModel> getPresets() {
    final String? raw = _prefs.getString(AppConstants.keyPresets);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => PresetModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePresets(List<PresetModel> presets) {
    final String raw = jsonEncode(presets.map((e) => e.toJson()).toList());
    return _prefs.setString(AppConstants.keyPresets, raw);
  }

  // ---- Favorites (crosshair type names) ------------------------------
  Set<String> getFavoriteTypeNames() {
    return (_prefs.getStringList(AppConstants.keyFavorites) ?? <String>[]).toSet();
  }

  Future<void> saveFavoriteTypeNames(Set<String> names) {
    return _prefs.setStringList(AppConstants.keyFavorites, names.toList());
  }

  // ---- Profiles --------------------------------------------------------
  List<ProfileModel> getProfiles() {
    final String? raw = _prefs.getString(AppConstants.keyProfiles);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProfiles(List<ProfileModel> profiles) {
    final String raw = jsonEncode(profiles.map((e) => e.toJson()).toList());
    return _prefs.setString(AppConstants.keyProfiles, raw);
  }

  String? get activeProfileId => _prefs.getString(AppConstants.keyActiveProfileId);
  Future<void> setActiveProfileId(String id) => _prefs.setString(AppConstants.keyActiveProfileId, id);
}
