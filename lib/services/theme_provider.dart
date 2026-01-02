import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Default to dark mode as per your current design
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // This tells the app to rebuild with the new theme
  }
}
