import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Central Material 3 theming for AIMORA.
///
/// Typography: `Sora` for display/headline (a geometric, technical
/// typeface that reads as "gaming precision") paired with `Inter` for
/// body/label text (excellent legibility at small sizes for sliders,
/// settings rows, etc).
class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color onSurface) {
    final TextTheme base = TextTheme(
      displayLarge: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 40, color: onSurface),
      displayMedium: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 32, color: onSurface),
      headlineLarge: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 28, color: onSurface),
      headlineMedium: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 24, color: onSurface),
      headlineSmall: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 20, color: onSurface),
      titleLarge: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 18, color: onSurface),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: onSurface),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: onSurface),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: onSurface),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: onSurface),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: onSurface),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: onSurface),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12, color: onSurface),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11, color: onSurface),
    );
    return base;
  }

  static ThemeData get dark {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cyan,
      brightness: Brightness.dark,
      primary: AppColors.cyan,
      secondary: AppColors.violet,
      surface: AppColors.darkSurface,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.navyTop,
      textTheme: _textTheme(AppColors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: AppColors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.cyan,
        inactiveTrackColor: AppColors.darkSurfaceVariant,
        thumbColor: AppColors.cyan,
        overlayColor: AppColors.cyan.withValues(alpha: 0.15),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.cyan : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.cyan.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.cyan,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.cyan.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.white),
        ),
      ),
      dividerColor: Colors.white12,
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cyan,
      brightness: Brightness.light,
      primary: const Color(0xFF00B8D4),
      secondary: AppColors.violet,
      surface: AppColors.lightSurface,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightSurface,
      textTheme: _textTheme(const Color(0xFF10131F)),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: const Color(0xFF10131F),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B8D4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF00B8D4),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: Colors.black12,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
