import 'package:flutter/material.dart';
import 'package:my_auth_project/screens/motivation/motivation_tab.dart';
import 'package:my_auth_project/screens/progress/progress_tab.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/theme_provider.dart';

// Ensure these imports point to where you actually saved the files
import 'package:my_auth_project/screens/home/home_tab.dart';
import 'package:my_auth_project/screens/settings/settings_tab.dart';

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
    const MotivationTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor: isDark
            ? Colors.blueAccent.withOpacity(0.2)
            : Colors.blue.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Motivation',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
