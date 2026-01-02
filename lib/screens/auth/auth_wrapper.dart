import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/habit_provider.dart'; // Import Provider
import 'package:my_auth_project/screens/auth/auth_page.dart';
import 'package:my_auth_project/screens/home/navbar.dart';
import 'package:my_auth_project/screens/auth/onboarding_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // 1. Waiting for Firebase Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. User is Logged In -> Check their Habits
        if (snapshot.hasData) {
          return const HabitGuard();
        }

        // 3. User is NOT Logged In -> Show Login/Signup
        return const AuthPage();
      },
    );
  }
}

/// This widget is the "Traffic Controller"
/// It checks if the user has any habits in the subcollection.
class HabitGuard extends StatefulWidget {
  const HabitGuard({super.key});

  @override
  State<HabitGuard> createState() => _HabitGuardState();
}

class _HabitGuardState extends State<HabitGuard> {
  @override
  void initState() {
    super.initState();
    // Fetch habits as soon as the user logs in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).fetchHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        // A. Still fetching data? Show Loading.
        if (habitProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // B. List is empty? -> User needs to set up their first habit.
        if (habitProvider.habits.isEmpty) {
          return const OnboardingScreen();
        }

        // C. Habits exist? -> Go to Home
        return const Navbar();
      },
    );
  }
}
