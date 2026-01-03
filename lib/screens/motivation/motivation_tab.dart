import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';
import 'emergency_screen.dart';

// --- CUSTOM WIDGET IMPORTS ---
import 'package:my_auth_project/screens/motivation/widget/jar_widget.dart';
import 'wisdom_screen.dart';

class MotivationTab extends StatefulWidget {
  const MotivationTab({super.key});

  @override
  State<MotivationTab> createState() => _MotivationTabState();
}

class _MotivationTabState extends State<MotivationTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

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

                      // 1. SUPPORT BUTTON
                      SupportButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EmergencyScreen(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 2. MANIFESTO CARD
                      _buildGlassCard(
                        isDark: isDark,
                        child: _buildReasonContent(rootWhy, isDark),
                      ),

                      const SizedBox(height: 32),

                      // 3. WISDOM SECTION
                      _buildJarSection(context, isDark),

                      const SizedBox(height: 32),

                      // 4. BENEFITS (Gratitude Journal Style)
                      _buildJournalCardSection(
                        title: "Benefits of Recovery",
                        items: gains,
                        accentColor: const Color(0xFF10B981), // Emerald
                        icon: PhosphorIcons.plant(),
                        placeholder: "Add a benefit...",
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

                      const SizedBox(height: 32),

                      // 5. CONSEQUENCES (Gratitude Journal Style)
                      _buildJournalCardSection(
                        title: "Consequences of Use",
                        items: losses,
                        accentColor: const Color(0xFFEF4444), // Red
                        icon: PhosphorIcons.warning(),
                        placeholder: "Add a consequence...",
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

  // --- NEW: JOURNAL STYLE CARD SECTION ---
  // This unifies Header, List, and Add Input into one card like the reference image
  Widget _buildJournalCardSection({
    required String title,
    required List<dynamic> items,
    required Color accentColor,
    required IconData icon,
    required String placeholder,
    required bool isDark,
    required VoidCallback onAdd,
    required Function(dynamic) onDelete,
  }) {
    return _buildGlassCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. HEADER
            Row(
              children: [
                Icon(icon, color: accentColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily:
                        'Georgia', // Optional: Serif font like reference
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // B. LIST ITEMS (Pills)
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "Nothing here yet.",
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(item),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(PhosphorIcons.trash(), color: Colors.red),
                        ),
                        onDismissed: (_) => onDelete(item),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? accentColor.withOpacity(0.08)
                                : accentColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentColor.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            item.toString(),
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate(delay: (50 * index).ms)
                    .fadeIn()
                    .slideX(begin: 0.05, end: 0);
              }),

            const SizedBox(height: 16),
            Divider(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
            const SizedBox(height: 12),

            // C. ADD INPUT TRIGGER (Looks like input, acts like button)
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        placeholder,
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 18, color: accentColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: DELETE BACKGROUND (Simplified) ---
  Widget _buildDeleteBackground() {
    return Container(); // Handled inline in Dismissible above for cleaner custom look
  }

  // --- EXISTING GLASS CARD HELPER ---
  Widget _buildGlassCard({required Widget child, required bool isDark}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // --- EXISTING MANIFESTO CONTENT ---
  Widget _buildReasonContent(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            "MY MAIN REASON",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : Colors.black54,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            PhosphorIcons.quotes(), // FIXED: Added ()
            size: 32,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // --- EXISTING JAR SECTION ---
  Widget _buildJarSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "DAILY WISDOM",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedWisdomScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Wisdom Room",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      PhosphorIcons.arrowRight(), // FIXED: Added ()
                      size: 12,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const JarOfWisdom(),
      ],
    );
  }

  // --- LOGIC: ADD/DELETE ---
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
            border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
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

                    if (context.mounted) {
                      Provider.of<HabitProvider>(
                        context,
                        listen: false,
                      ).fetchHabits();
                    }
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

// --- SUPPORT BUTTON (Solid Action Button) ---
class SupportButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SupportButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE11D48),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
          shadowColor: const Color(0xFFE11D48).withOpacity(0.4),
        ),
        icon: Icon(PhosphorIcons.lifebuoy(), size: 24),
        label: const Text(
          "Urge Assistance",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}
