import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:my_auth_project/services/theme_provider.dart';

// Screens
import 'package:my_auth_project/screens/home/home_tab.dart';
import 'package:my_auth_project/screens/progress/progress_tab.dart';
import 'package:my_auth_project/screens/motivation/motivation_tab.dart';
import 'package:my_auth_project/screens/settings/settings_tab.dart';

// --- FIXED IMPORT ---
// We now point to the new file name: support_hub.dart
import 'package:my_auth_project/screens/journal/support_hub.dart';

import '../../widgets/global_app_bar.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ProgressTab(),
    const CommunityTab(), // This matches the class name inside support_hub.dart
    const MotivationTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlobalAppBar(),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        indicatorColor: isDark
            ? Colors.blueAccent.withOpacity(0.2)
            : Colors.blue.withOpacity(0.1),
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIcons.house()),
            selectedIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.chartBar()),
            selectedIcon: Icon(PhosphorIcons.chartBar(PhosphorIconsStyle.fill)),
            label: 'Progress',
          ),
          // --- UPDATED LABEL & ICON ---
          NavigationDestination(
            icon: Icon(PhosphorIcons.lifebuoy()),
            selectedIcon: Icon(PhosphorIcons.lifebuoy(PhosphorIconsStyle.fill)),
            label: 'Support Hub',
          ),
          // ----------------------------
          NavigationDestination(
            icon: Icon(PhosphorIcons.lightning()),
            selectedIcon: Icon(
              PhosphorIcons.lightning(PhosphorIconsStyle.fill),
            ),
            label: 'Motivation',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.gear()),
            selectedIcon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.fill)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
