import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'gallery_screen.dart';
import 'overlay_control_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

/// Root shell after onboarding: a bottom navigation bar switching between
/// the four main sections of AIMORA.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<Widget> _tabs = [
    OverlayControlScreen(),
    GalleryScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.gps_fixed_rounded), label: 'crosshair_control'.tr()),
          NavigationDestination(icon: const Icon(Icons.grid_view_rounded), label: 'gallery'.tr()),
          NavigationDestination(icon: const Icon(Icons.person_rounded), label: 'profile'.tr()),
          NavigationDestination(icon: const Icon(Icons.settings_rounded), label: 'settings'.tr()),
        ],
      ),
    );
  }
}
