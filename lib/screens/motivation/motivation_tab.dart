import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart'; // 🟢 ADDED THIS IMPORT

import 'package:my_auth_project/screens/motivation/ai_chat_creen.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';
import 'emergency_screen.dart';

import 'package:my_auth_project/screens/journal/widgets/add_trigger_sheet.dart';

// --- WIDGET IMPORTS ---
import 'widget/ambient_background.dart';
import 'widget/stress_popper.dart';
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

class _MotivationTabState extends State<MotivationTab> {
  int _selectedIndex = 0;

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

        // --- DATA PREPARATION ---
        dynamic rawMotivation = currentHabit.motivation;
        List<dynamic> motivationList = [];
        if (rawMotivation is List) {
          motivationList = rawMotivation;
        } else {
          motivationList = [rawMotivation.toString()];
        }

        final List<dynamic> gains = currentHabit.gains;
        final List<dynamic> losses = currentHabit.losses;
        final List<dynamic> gratitude = currentHabit.gratitude;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              AmbientBackground(isDark: isDark),

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

                      // --- 1. AI PEPTALK (Now with GLITTER!) ---
                      _buildAiPeptalkCard(context, isDark),
                      const SizedBox(height: 24),

                      // --- 2. TOOLKIT ROW ---
                      Row(
                        children: [
                          Expanded(
                            child: SupportButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const EmergencyScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StressPopperScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.blueAccent.withOpacity(0.2)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.blueAccent.withOpacity(0.5)
                                        : Colors.blue.withOpacity(0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIcons.circlesFour(
                                        PhosphorIconsStyle.fill,
                                      ),
                                      color: Colors.blueAccent,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Stress Poppers",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // --- 3. MANIFESTO CARD ---
                      ManifestoCard(
                        items: motivationList,
                        isDark: isDark,
                        uid: user?.uid,
                        habitId: currentHabit.id,
                      ),

                      const SizedBox(height: 32),

                      // --- 4. TAB SWITCHER ---
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
                            habitProvider: habitProvider,
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

  // --- WIDGETS ---

  // 🟢 UPDATED: Magical Glitter Effect Added
  Widget _buildAiPeptalkCard(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AiChatScreen()),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child:
          Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ], // Indigo to Purple
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 🟢 SPARKLE ICON ANIMATION (Pulsing & Rotating)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:
                          const Icon(
                                PhosphorIconsFill.sparkle,
                                color: Colors.white,
                                size: 24,
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .scaleXY(
                                begin: 1.0,
                                end: 1.2,
                                duration: 1.5.seconds,
                                curve: Curves.easeInOut,
                              ) // Breathe
                              .rotate(
                                begin: -0.05,
                                end: 0.05,
                                duration: 2.seconds,
                              ), // Subtle wiggle
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Need a Strategy?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Chat with the AI Coach.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(PhosphorIcons.caretRight(), color: Colors.white70),
                  ],
                ),
              )
              // 🟢 CARD GLITTER ANIMATION (Shimmer Sweep)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 2.5.seconds, // Speed of the glitter pass
                color: Colors.white.withOpacity(0.3), // Color of the "shine"
                angle: 120, // Diagonal sweep
              ),
    );
  }

  // --- TRIGGER TRACKER WIDGETS --- (Rest of file remains unchanged)

  Widget _buildTriggerSectionHeader(
    BuildContext context,
    String habitId,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Trigger Log",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddTriggerSheet(habitId: habitId, isDark: isDark),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(PhosphorIconsFill.plus, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  "Log New",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTriggerList(
    HabitProvider provider,
    String habitId,
    bool isDark,
    BuildContext context,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: provider.getTriggerLogsStream(habitId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey[200]!,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  PhosphorIcons.checkCircle(),
                  color: Colors.greenAccent,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  "No triggers logged yet.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Staying clean? That's amazing!",
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final logs = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = logs[index];
            final data = doc.data() as Map<String, dynamic>;
            final intensity = data['intensity'] ?? 0;

            return Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  PhosphorIcons.trash(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              onDismissed: (_) => provider.deleteTriggerLog(habitId, doc.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey[100]!,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getColorForIntensity(intensity),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['triggerName'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (data['note'] != null && data['note'].isNotEmpty)
                            Text(
                              data['note'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      "$intensity/10",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _getColorForIntensity(intensity),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getColorForIntensity(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.orange;
    return Colors.redAccent;
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
    required HabitProvider habitProvider,
  }) {
    switch (index) {
      case 0: // Wisdom
        return WisdomSection(isDark: isDark);
      case 1: // Benefits
        return Column(
          children: [
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
      case 2: // Risks
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
      case 3: // Triggers
        return Column(
          children: [
            _buildTriggerSectionHeader(context, currentHabit.id, isDark),
            const SizedBox(height: 16),
            _buildCompactTriggerList(
              habitProvider,
              currentHabit.id,
              isDark,
              context,
            ),
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
          _buildTabItem("Triggers", 3, isDark),
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
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
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
              fontSize: 13,
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
    if (context.mounted) {
      Provider.of<HabitProvider>(context, listen: false).fetchHabits();
    }
  }
}
