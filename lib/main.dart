import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // <--- Added Google Fonts Import

// Import your providers and screens
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/screens/auth/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Reset',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      // --- LIGHT THEME ---
      theme: _buildTheme(Brightness.light),

      // --- DARK THEME ---
      darkTheme: _buildTheme(Brightness.dark),

      home: const AuthWrapper(),
    );
  }

  // Helper method to build a consistent theme with the Inter font
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Your custom background colors
    final bgColor = isDark ? const Color(0xFF020817) : const Color(0xFFF8F9FE);

    // 1. Create the base Theme
    var baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: brightness,
        // Ensure the background in color scheme matches scaffold
        background: bgColor,
        surface: bgColor,
      ),
    );

    // 2. Apply the "Inter" font to the entire text theme
    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
    );
  }
}
