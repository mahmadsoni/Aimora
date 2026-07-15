import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_logo.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final Stopwatch sw = Stopwatch()..start();
    final bool onboardingDone = ref.read(storageServiceProvider).isOnboardingDone;

    final int remaining = AppConstants.splashMinDuration.inMilliseconds - sw.elapsedMilliseconds;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
    if (!mounted) return;

    unawaited(
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => onboardingDone ? const HomeScreen() : const OnboardingScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 140, animate: true),
              const SizedBox(height: 28),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'app_tagline'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.cyan),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
