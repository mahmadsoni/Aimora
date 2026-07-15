/// Global constants shared across the AIMORA codebase.
class AppConstants {
  AppConstants._();

  static const String appName = 'AIMORA';
  static const String appTagline = 'Precision. Overlay. Victory.';
  static const String githubUsername = 'Mahmadsoni';
  static const String repoUrl = 'https://github.com/Mahmadsoni/aimora';

  // SharedPreferences keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale_code';
  static const String keyProfiles = 'profiles_v1';
  static const String keyActiveProfileId = 'active_profile_id';
  static const String keyPresets = 'presets_v1';
  static const String keyFavorites = 'favorite_type_ids_v1';
  static const String keyOverlayConfig = 'overlay_config_v1';
  static const String keyOverlayRunning = 'overlay_running_v1';

  // Design constraints for the crosshair editor
  static const double minCrosshairSize = 10;
  static const double maxCrosshairSize = 120;
  static const double minThickness = 1;
  static const double maxThickness = 12;
  static const double minGap = 0;
  static const double maxGap = 40;
  static const double minOpacity = 0.1;
  static const double maxOpacity = 1.0;

  static const Duration splashMinDuration = Duration(milliseconds: 1600);
}
