import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';
import 'emergency_screen.dart';

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
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            ...List.generate(15, (index) {
              double startX =
                  (index * 40.0) % MediaQuery.of(context).size.width;
              double startY =
                  (index * 70.0) % MediaQuery.of(context).size.height;
              double currentX =
                  (startX + (_bgController.value * 200)) %
                  MediaQuery.of(context).size.width;
              double currentY =
                  (startY - (_bgController.value * 300)) %
                  MediaQuery.of(context).size.height;

              return Positioned(
                left: currentX,
                top: currentY,
                child: Container(
                  width: (index % 3 + 2).toDouble(),
                  height: (index % 3 + 2).toDouble(),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.blue.withOpacity(0.2),
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
          body: Stack(
            children: [
              _buildAnimatedBackground(isDark),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      Text(
                        "REMEMBER YOUR WHY",
                        style: TextStyle(
                          color: isDark ? const Color(0xFFCDBEFA) : Colors.blue,
                          letterSpacing: 1.5,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Daily Motivation",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // NEW: Replaced helper method with the Breathing Widget class
                      BreathingPanicButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EmergencyScreen(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildSectionHeader(
                        "The Root Purpose",
                        Icons.anchor_rounded,
                      ),
                      _buildMotivationCard(rootWhy, isDark),

                      const SizedBox(height: 32),
                      _buildListSection(
                        context,
                        user?.uid,
                        currentHabit.id,
                        "What I gain",
                        "gains",
                        gains,
                        const Color(0xFF2DD4BF),
                        isDark,
                      ),

                      const SizedBox(height: 32),
                      _buildListSection(
                        context,
                        user?.uid,
                        currentHabit.id,
                        "What I lose",
                        "losses",
                        losses,
                        Colors.redAccent,
                        isDark,
                      ),
                      const SizedBox(height: 40),
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

  // --- HELPER METHODS ---

  Widget _buildListSection(
    BuildContext context,
    String? uid,
    String habitId,
    String title,
    String dbKey,
    List<dynamic> items,
    Color accentColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(title, Icons.list_rounded),
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: accentColor,
                size: 24,
              ),
              onPressed: () =>
                  _showAddSheet(context, uid, habitId, title, dbKey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            // NEW: Dismissible wrapper for Swipe-to-Delete
            child: Dismissible(
              key: ValueKey(item), // Assumes items are unique strings
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
              onDismissed: (direction) {
                _deleteItem(context, uid, habitId, dbKey, item);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        // Removed the old 'X' IconButton here
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NEW ${title.toUpperCase()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 14,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter reason...",
                    hintStyle: const TextStyle(color: Colors.grey),
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
                          })
                          .catchError((e) => debugPrint("Sync error: $e"));

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
                    child: const Text(
                      "ADD TO LIST",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildSectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
      ],
    ),
  );

  Widget _buildMotivationCard(String text, bool isDark) => ClipRRect(
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
        child: Text(
          "\"$text\"",
          style: TextStyle(
            fontSize: 17,
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white : Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    ),
  );
}

// --- NEW CLASS: BREATHING PANIC BUTTON ---
// Placed here for easy access, but ideally moved to 'widgets/breathing_button.dart'
class BreathingPanicButton extends StatefulWidget {
  final VoidCallback onPressed;
  const BreathingPanicButton({super.key, required this.onPressed});

  @override
  State<BreathingPanicButton> createState() => _BreathingPanicButtonState();
}

class _BreathingPanicButtonState extends State<BreathingPanicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Slow, calming breath
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFB91C1C,
                  ).withOpacity(0.4 * _controller.value),
                  blurRadius: 15 + (10 * _controller.value),
                  spreadRadius: 2 * _controller.value,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.bolt_rounded),
              label: const Text(
                "PANIC BUTTON",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
