import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/theme_provider.dart';
import '../services/habit_provider.dart';
import '../screens/profile/profile_screen.dart';
import 'habit_switcher.dart';
import 'user_avatar.dart'; // Ensure this points to your widget file

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final User? user = AuthService().currentUser;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withOpacity(0.6)
                  : Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            final currentHabit = habitProvider.selectedHabit;

            if (habitProvider.isLoading || currentHabit == null) {
              return const SizedBox();
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HabitSwitcher(habit: currentHabit, isDark: isDark),

                // 🟢 UPDATED: Use photoURL instead of User object
                UserAvatar(
                  photoURL: user?.photoURL, // Pass the String URL
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
