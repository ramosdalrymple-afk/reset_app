import 'package:flutter/material.dart';
import 'package:my_auth_project/screens/settings/widget/add_habit_sheet.dart';
import 'package:my_auth_project/screens/settings/widget/settings_card.dart';
import 'package:my_auth_project/screens/settings/widget/user_header.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';

// // Import your new widgets
// import 'widgets/settings_card.dart';
// import 'widgets/user_header.dart';
// import 'widgets/add_habit_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(
            isDark,
          ), // Keeping background logic here is fine
          Consumer<HabitProvider>(
            builder: (context, habitProvider, child) {
              final currentHabit = habitProvider.selectedHabit;

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

                      // 1. User Header (Extracted)
                      UserHeader(user: user),

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

                      // 2. Active Habit Card (Using SettingsCard)
                      SettingsCard(
                        title: "Active Habit",
                        subtitle: "Select which habit to track.",
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Habit>(
                                  value: currentHabit,
                                  isExpanded: true,
                                  dropdownColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  hint: const Text("Select a habit"),
                                  items: habitProvider.habits.map((Habit h) {
                                    return DropdownMenuItem<Habit>(
                                      value: h,
                                      child: Text(
                                        h.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Habit? newHabit) {
                                    if (newHabit != null) {
                                      habitProvider.selectHabit(newHabit);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const AddHabitSheet(),
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blueAccent.withOpacity(
                                  0.1,
                                ),
                                foregroundColor: Colors.blueAccent,
                              ),
                              icon: const Icon(Icons.add),
                            ),
                            if (currentHabit != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () =>
                                    _confirmDelete(context, currentHabit),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  foregroundColor: Colors.red,
                                ),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. Appearance Card
                      SettingsCard(
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

                      // 4. Account Actions Card
                      SettingsCard(
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

  // Helper for Theme Icons
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

  // Delete Dialog Logic
  void _confirmDelete(BuildContext context, Habit habit) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        title: const Text("Delete Habit?"),
        content: Text("Are you sure you want to delete '${habit.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<HabitProvider>(
                context,
                listen: false,
              ).deleteHabit(habit.id);
            },
            child: const Text(
              "DELETE",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Background Animation
  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
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
}
