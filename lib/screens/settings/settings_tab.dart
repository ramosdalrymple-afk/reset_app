import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  // NEW: Vertical "Data Stream" Background
  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            // Create several vertical drifting lines
            ...List.generate(5, (index) {
              double leftPadding =
                  (MediaQuery.of(context).size.width / 5) * index;
              return Positioned(
                left: leftPadding + 20,
                top:
                    -200 +
                    (MediaQuery.of(context).size.height + 200) *
                        ((_bgController.value + (index * 0.2)) % 1.0),
                child: Container(
                  width: 2,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        isDark
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(isDark),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final String habitName = data['habitName'] ?? "Habit";

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildUserHeader(user, isDark),
                      const SizedBox(height: 40),
                      const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const Text(
                        "Manage your journey and preferences.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      // 1. HABIT SECTION
                      _buildSettingsCard(
                        context,
                        title: "Habit",
                        subtitle: "The habit you are currently tracking.",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              habitName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 2. APPEARANCE SECTION
                      _buildSettingsCard(
                        context,
                        title: "Appearance",
                        subtitle: "Choose your preferred color theme.",
                        child: Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Theme",
                                  style: TextStyle(fontSize: 18),
                                ),
                                Row(
                                  children: [
                                    _buildThemeIcon(
                                      Icons.light_mode_outlined,
                                      !themeProvider.isDarkMode,
                                      () => themeProvider.toggleTheme(false),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildThemeIcon(
                                      Icons.dark_mode_outlined,
                                      themeProvider.isDarkMode,
                                      () => themeProvider.toggleTheme(true),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. DANGER ZONE
                      _buildSettingsCard(
                        context,
                        title: "Account Actions",
                        subtitle: "Sign out or manage your data.",
                        titleColor: const Color(0xFFEF4444),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => AuthService().signOut(),
                            icon: const Icon(Icons.logout),
                            label: const Text("Sign Out"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFEF4444,
                              ).withOpacity(0.1),
                              foregroundColor: const Color(0xFFEF4444),
                              elevation: 0,
                              side: const BorderSide(
                                color: Color(0xFFEF4444),
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(var user, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 35,
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.blue[50],
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 35,
                    color: isDark ? const Color(0xFFCDBEFA) : Colors.blue,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.displayName ?? "Champion",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              user?.email ?? "No email linked",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeIcon(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
    Color? titleColor,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor ?? (isDark ? Colors.white : Colors.black),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
