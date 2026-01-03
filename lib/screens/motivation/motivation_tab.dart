import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_auth_project/screens/motivation/widget/consequences_card.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';
import 'emergency_screen.dart';

// --- WIDGET IMPORTS ---
import 'widget/support_button.dart';
import 'widget/manifesto_card.dart';
import 'widget/benefits_card.dart';
import 'widget/gratitude_card.dart';
import 'widget/consequences_card.dart';
import 'widget/resource_library.dart';
import 'widget/wisdom_section.dart';

class MotivationTab extends StatefulWidget {
  const MotivationTab({super.key});

  @override
  State<MotivationTab> createState() => _MotivationTabState();
}

class _MotivationTabState extends State<MotivationTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  // --- BACKGROUND ---
  Widget _buildAmbientBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            Positioned(
              top: -100 + (50 * _bgController.value),
              left: -50,
              child: _buildOrb(
                300,
                isDark ? Colors.purpleAccent : Colors.blueAccent,
                isDark,
              ),
            ),
            Positioned(
              bottom: -100 + (50 * _bgController.value),
              right: -50,
              child: _buildOrb(
                300,
                isDark ? Colors.tealAccent : Colors.cyanAccent,
                isDark,
              ),
            ),
            Positioned(
              top: 300 + (100 * _bgController.value),
              left: -100 + (200 * _bgController.value),
              child: _buildOrb(
                250,
                isDark ? Colors.indigoAccent : Colors.blue,
                isDark,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrb(double size, Color color, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(isDark ? 0.15 : 0.2),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final currentHabit = habitProvider.selectedHabit;

        if (currentHabit == null) {
          return const Center(child: Text("No habit selected"));
        }

        final String rootWhy = currentHabit.motivation;
        final List<dynamic> gains = currentHabit.gains;
        final List<dynamic> losses = currentHabit.losses;
        // Ensure the model has been updated to include 'gratitude'
        final List<dynamic> gratitude = currentHabit.gratitude;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              _buildAmbientBackground(isDark),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // --- HEADER ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "RECOVERY JOURNAL",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              letterSpacing: 1.2,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "My Motivation",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SupportButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EmergencyScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ManifestoCard(text: rootWhy, isDark: isDark),
                      const SizedBox(height: 32),

                      // --- TAB SWITCHER (3 Tabs) ---
                      _buildTabSwitch(isDark),
                      const SizedBox(height: 20),

                      // --- CONTENT SWITCHER ---
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: KeyedSubtree(
                          key: ValueKey<int>(_selectedIndex),
                          child: _buildSelectedContent(
                            index: _selectedIndex,
                            isDark: isDark,
                            gains: gains,
                            losses: losses,
                            gratitude: gratitude,
                            user: user,
                            currentHabit: currentHabit,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- CONTENT SELECTOR ---
  Widget _buildSelectedContent({
    required int index,
    required bool isDark,
    required List<dynamic> gains,
    required List<dynamic> losses,
    required List<dynamic> gratitude,
    required dynamic user,
    required Habit currentHabit,
  }) {
    switch (index) {
      case 0:
        return WisdomSection(isDark: isDark);
      case 1:
        // --- BENEFITS TAB (Includes Benefits + Gratitude) ---
        return Column(
          children: [
            // 1. Benefits of Recovery
            BenefitsCard(
              items: gains,
              isDark: isDark,
              onAdd: () => _showAddSheet(
                context,
                user?.uid,
                currentHabit.id,
                "Benefits",
                "gains",
              ),
              onDelete: (item) => _deleteItem(
                context,
                user?.uid,
                currentHabit.id,
                "gains",
                item,
              ),
            ),
            const SizedBox(height: 24),

            // 2. Gratitude Journal (Below Benefits)
            GratitudeCard(
              items: gratitude,
              isDark: isDark,
              onAdd: () => _showAddSheet(
                context,
                user?.uid,
                currentHabit.id,
                "Gratitude",
                "gratitude",
              ),
              onDelete: (item) => _deleteItem(
                context,
                user?.uid,
                currentHabit.id,
                "gratitude",
                item,
              ),
            ),
          ],
        );
      case 2:
        // --- RISKS TAB (Includes Consequences + Resources) ---
        return Column(
          children: [
            ConsequencesCard(
              items: losses,
              isDark: isDark,
              onAdd: () => _showAddSheet(
                context,
                user?.uid,
                currentHabit.id,
                "Consequences",
                "losses",
              ),
              onDelete: (item) => _deleteItem(
                context,
                user?.uid,
                currentHabit.id,
                "losses",
                item,
              ),
            ),
            const SizedBox(height: 24),
            ResourceLibrary(isDark: isDark),
          ],
        );
      default:
        return Container();
    }
  }

  // --- TAB SWITCHER UI ---
  Widget _buildTabSwitch(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTabItem("Wisdom", 0, isDark),
          _buildTabItem("Benefits", 1, isDark),
          _buildTabItem("Risks", 2, isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, bool isDark) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white.withOpacity(0.1) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.white54 : Colors.black54),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIC HELPERS ---
  void _showAddSheet(
    BuildContext context,
    String? uid,
    String habitId,
    String title,
    String key,
  ) {
    final controller = TextEditingController();
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add to $title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Type here...",
                  filled: true,
                  fillColor: isDark ? Colors.black26 : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    Navigator.of(sheetContext).pop();
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('habits')
                        .doc(habitId)
                        .update({
                          key: FieldValue.arrayUnion([text]),
                        });
                    if (context.mounted)
                      Provider.of<HabitProvider>(
                        context,
                        listen: false,
                      ).fetchHabits();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteItem(
    BuildContext context,
    String? uid,
    String habitId,
    String key,
    dynamic item,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habitId)
        .update({
          key: FieldValue.arrayRemove([item]),
        });
    if (context.mounted)
      Provider.of<HabitProvider>(context, listen: false).fetchHabits();
  }
}
