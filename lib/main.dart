import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash_screen.dart';

// Re-exported so the pragma'd entry point below is retained by the
// compiler and reachable by name for `flutter_overlay_window`.
export 'overlay/overlay_main.dart' show overlayMain;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Defense-in-depth: if a widget ever throws during build, show a small
  // friendly fallback instead of Flutter's raw red error screen — keeps
  // the rest of the app (bottom navigation, other tabs) usable.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const ColoredBox(
      color: Color(0xFF11162A),
      child: Center(
        child: Icon(Icons.error_outline_rounded, color: Colors.white38, size: 32),
      ),
    );
  };

  final StorageService storage = await StorageService.create();

  await EasyLocalization.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru'), Locale('tg')],
        path: 'assets/lang',
        fallbackLocale: const Locale('en'),
        startLocale: storage.localeCode != null ? Locale(storage.localeCode!) : null,
        child: const AimoraApp(),
      ),
    ),
  );
}

class AimoraApp extends ConsumerWidget {
  const AimoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'AIMORA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashScreen(),
    );
  }
}
