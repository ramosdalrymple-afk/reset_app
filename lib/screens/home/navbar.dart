import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:my_auth_project/services/theme_provider.dart';

// Screens
import 'package:my_auth_project/screens/home/home_tab.dart';
import 'package:my_auth_project/screens/progress/progress_tab.dart';
import 'package:my_auth_project/screens/motivation/motivation_tab.dart';
import 'package:my_auth_project/screens/settings/settings_tab.dart';
import 'package:my_auth_project/screens/journal/community_tab.dart';

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
    const CommunityTab(),
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
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              );
            }
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: isDark ? Colors.white54 : Colors.black54,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return IconThemeData(
                size: 22,
                color: isDark ? Colors.white : Colors.black,
              );
            }
            return IconThemeData(
              size: 22,
              color: isDark ? Colors.white54 : Colors.black54,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          height: 70,
          indicatorColor: isDark
              ? Colors.blueAccent.withOpacity(0.15)
              : Colors.blue.withOpacity(0.1),
          animationDuration: const Duration(milliseconds: 600),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(PhosphorIcons.house()),
              selectedIcon: _buildAnimatedIcon(
                PhosphorIcons.house(PhosphorIconsStyle.fill),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIcons.chartBar()),
              selectedIcon: _buildAnimatedIcon(
                PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
              ),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIcons.lifebuoy()),
              selectedIcon: _buildAnimatedIcon(
                PhosphorIcons.lifebuoy(PhosphorIconsStyle.fill),
              ),
              label: 'Community',
            ),
            // 🟢 UPDATED DESTINATION
            NavigationDestination(
              // Using 'notebook' is classic for journaling
              icon: Icon(PhosphorIcons.notebook()),
              selectedIcon: _buildAnimatedIcon(
                PhosphorIcons.notebook(PhosphorIconsStyle.fill),
              ),
              label: 'Motivation', // Changed from "Inspire" to "Journal"
            ),
            // ---------------------
            NavigationDestination(
              icon: Icon(PhosphorIcons.gear()),
              selectedIcon: _buildAnimatedIcon(
                PhosphorIcons.gear(PhosphorIconsStyle.fill),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData iconData) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: Icon(iconData));
      },
    );
  }
}
