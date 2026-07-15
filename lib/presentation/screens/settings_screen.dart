import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_logo.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with WidgetsBindingObserver {
  bool _overlayGranted = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
    _loadVersion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final bool granted = await ref.read(permissionServiceProvider).hasOverlayPermission();
    if (mounted) setState(() => _overlayGranted = granted);
  }

  Future<void> _loadVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode mode = ref.watch(themeModeProvider);
    final Locale locale = context.locale;

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _Header('settings_permissions'.tr()),
          ListTile(
            leading: Icon(
              _overlayGranted ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
              color: _overlayGranted ? AppColors.success : AppColors.warning,
            ),
            title: Text('settings_permissions'.tr()),
            subtitle: Text('settings_permission_desc'.tr()),
            trailing: _overlayGranted
                ? Text('settings_granted'.tr())
                : TextButton(
                    onPressed: () async {
                      await ref.read(permissionServiceProvider).requestOverlayPermission();
                      await _refreshPermission();
                    },
                    child: Text('settings_grant'.tr()),
                  ),
          ),
          const Divider(),

          _Header('settings_appearance'.tr()),
          ListTile(
            title: Text('settings_theme'.tr()),
            trailing: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.system, label: Text('theme_system'.tr())),
                ButtonSegment(value: ThemeMode.light, label: Text('theme_light'.tr())),
                ButtonSegment(value: ThemeMode.dark, label: Text('theme_dark'.tr())),
              ],
              selected: {mode},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).setMode(s.first),
            ),
          ),
          const Divider(),

          _Header('settings_language'.tr()),
          ...context.supportedLocales.map(
            (l) => RadioListTile<Locale>(
              value: l,
              groupValue: locale,
              title: Text(_languageName(l)),
              onChanged: (value) async {
                if (value == null) return;
                await context.setLocale(value);
                await ref.read(storageServiceProvider).setLocaleCode(value.languageCode);
              },
            ),
          ),
          const Divider(),

          _Header('settings_about'.tr()),
          const SizedBox(height: 12),
          const Center(child: AppLogo(size: 72)),
          const SizedBox(height: 12),
          Center(
            child: Text(AppConstants.appName, style: Theme.of(context).textTheme.titleLarge),
          ),
          Center(
            child: Text('${'settings_version'.tr()}: $_version', style: Theme.of(context).textTheme.bodySmall),
          ),
          Center(
            child: Text(
              '${'settings_developer'.tr()}: ${AppConstants.githubUsername}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _languageName(Locale l) {
    switch (l.languageCode) {
      case 'ru':
        return 'Русский';
      case 'tg':
        return 'Тоҷикӣ';
      default:
        return 'English';
    }
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.cyan, fontWeight: FontWeight.w700),
      ),
    );
  }
}
