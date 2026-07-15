import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';
import '../widgets/crosshair_preview.dart';
import '../../data/models/crosshair_model.dart';
import '../../domain/entities/crosshair_type.dart';
import 'home_screen.dart';

class _OnboardPage {
  const _OnboardPage(this.titleKey, this.descKey, this.type, this.color);
  final String titleKey;
  final String descKey;
  final CrosshairType type;
  final Color color;
}

const List<_OnboardPage> _pages = [
  _OnboardPage('onboarding_title_1', 'onboarding_desc_1', CrosshairType.cross, AppColors.cyan),
  _OnboardPage('onboarding_title_2', 'onboarding_desc_2', CrosshairType.sniper, AppColors.violet),
  _OnboardPage('onboarding_title_3', 'onboarding_desc_3', CrosshairType.neon, AppColors.success),
  _OnboardPage('onboarding_title_4', 'onboarding_desc_4', CrosshairType.cyber, AppColors.warning),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  Future<void> _finish() async {
    await ref.read(storageServiceProvider).setOnboardingDone(true);
    if (!mounted) return;
    unawaited(Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen())));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextButton(
                  onPressed: _finish,
                  child: Text('skip'.tr()),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final _OnboardPage page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [page.color.withValues(alpha: 0.22), Colors.transparent],
                            ),
                          ),
                          child: Center(
                            child: CrosshairPreview(
                              size: 140,
                              backgroundColor: Colors.transparent,
                              config: CrosshairConfig.defaults().copyWith(
                                type: page.type,
                                colorValue: page.color.value,
                                size: 60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.titleKey.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.descKey.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final bool active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.cyan : Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                    }
                  },
                  child: Text(isLast ? 'get_started'.tr() : 'next'.tr()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
