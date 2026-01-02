import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/screens/auth/auth_page.dart';
import 'package:my_auth_project/screens/home/navbar.dart'; // Ensure this path is correct
import 'package:my_auth_project/screens/auth/onboarding_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // USER IS LOGGED IN -> Listen to their profile document
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Check if user document exists and has completed onboarding
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final data = userSnapshot.data!.data() as Map<String, dynamic>?;
                if (data != null && data['hasCompletedOnboarding'] == true) {
                  // UPDATED HERE: Changed HomeScreen() to Navbar()
                  return const Navbar();
                }
              }

              // If document doesn't exist or setup isn't done, show Onboarding
              return const OnboardingScreen();
            },
          );
        }

        // USER NOT LOGGED IN
        return const AuthPage();
      },
    );
  }
}
