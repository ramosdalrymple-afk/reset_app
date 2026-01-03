import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';
import 'package:my_auth_project/services/wisdom_service.dart';

// Widgets
import 'widgets/animated_background.dart';
import 'widgets/time_bar.dart';
import 'widgets/quote_card.dart';
import 'widgets/action_buttons.dart';
import 'widgets/weekly_calendar.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  Timer? _ticker;
  late AnimationController _bgController;
  WisdomItem? _dailyWisdom;
  bool _isLoadingQuote = true;

  @override
  void initState() {
    super.initState();
    _fetchNewQuote();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  Future<void> _fetchNewQuote() async {
    try {
      final item = await WisdomService().shakeTheJar();
      if (mounted) {
        setState(() {
          _dailyWisdom = item;
          _isLoadingQuote = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching quote: $e");
      if (mounted) setState(() => _isLoadingQuote = false);
    }
  }

  // --- NEW: Function to save to Firestore ---
  void _saveQuoteToVault() async {
    final user = AuthService().currentUser;
    if (user == null || _dailyWisdom == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_wisdom')
          .add({
            'text': _dailyWisdom!.text,
            'source': _dailyWisdom!.source,
            'type': _dailyWisdom!.type,
            'savedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Saved to your Wisdom Vault"),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving quote: $e");
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final currentHabit = habitProvider.selectedHabit;

        if (habitProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: isDark ? const Color(0xFFCDBEFA) : Colors.blue,
              ),
            ),
          );
        }

        if (currentHabit == null) {
          return const Scaffold(
            body: Center(child: Text("No habit selected. Check Settings.")),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              AnimatedBackground(controller: _bgController, isDark: isDark),
              _buildHomeContent(
                context,
                habitProvider,
                currentHabit,
                user,
                isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    HabitProvider habitProvider,
    Habit habit,
    User? user,
    bool isDark,
  ) {
    final Duration diff = DateTime.now().difference(habit.startDate);
    double secPercent = (diff.inSeconds % 60) / 60.0;
    double minPercent = (diff.inMinutes % 60) / 60.0;
    double hourPercent = (diff.inHours % 24) / 24.0;
    double dayPercent = (diff.inDays % 30) / 30.0;

    final now = DateTime.now();
    final String dateKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String? todayStatus = habit.history[dateKey];
    bool isAlreadyClean = todayStatus == 'clean';
    bool isStreakTooShort = diff.inSeconds < 30;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: kToolbarHeight),

                    // 1. HEADER
                    _buildHeader(habit.title, isDark),
                    const SizedBox(height: 20),

                    // 2. THE TRADEMARK TIMER
                    TimeBar(
                      value: "${diff.inDays}",
                      label: "days",
                      color: const Color(0xFF2DD4BF),
                      percentage: dayPercent,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    TimeBar(
                      value: "${diff.inHours % 24}",
                      label: "hours",
                      color: const Color(0xFF3B82F6),
                      percentage: hourPercent,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    TimeBar(
                      value: "${diff.inMinutes % 60}",
                      label: "minutes",
                      color: const Color(0xFF6366F1),
                      percentage: minPercent,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    TimeBar(
                      value: "${diff.inSeconds % 60}",
                      label: "seconds",
                      color: const Color(0xFF8B5CF6),
                      percentage: secPercent,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // 3. ACTION BUTTONS
                    ActionButtons(
                      isAlreadyClean: isAlreadyClean,
                      isStreakTooShort: isStreakTooShort,
                      onCleanTap: () => _confirmClean(context, habit),
                      onRelapseTap: () => _confirmReset(context, habit),
                    ),

                    const SizedBox(height: 32),

                    // 4. WEEKLY CHAIN
                    WeeklyCalendar(history: habit.history, isDark: isDark),

                    const SizedBox(height: 24),

                    // 5. QUOTE CARD (With Heart Functionality)
                    _isLoadingQuote
                        ? SizedBox(
                            height: 80,
                            child: Center(
                              child: Text(
                                "...",
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : QuoteCard(
                            isDark: isDark,
                            quote:
                                _dailyWisdom?.text ??
                                "Your best days are ahead.",
                            author: _dailyWisdom?.source ?? "Unknown",
                            // Pass the save function here
                            onSave: _saveQuoteToVault,
                          ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildHeader(String habitName, bool isDark) {
    return Column(
      children: [
        Text(
          "I've been $habitName free for",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  void _confirmClean(BuildContext context, Habit habit) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    showDialog(
      context: context,
      builder: (confirmContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text("Daily Check-in"),
          content: const Text("Victory logged! Did you stay clean today?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext),
              child: const Text(
                "NOT YET",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(confirmContext);
                await Provider.of<HabitProvider>(
                  context,
                  listen: false,
                ).markDayClean(habit.id);
              },
              child: const Text(
                "YES, I'M CLEAN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, Habit habit) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    String? selectedTrigger;
    final List<Map<String, dynamic>> triggers = [
      {'name': 'Stress', 'icon': Icons.bolt, 'color': Colors.orangeAccent},
      {'name': 'Boredom', 'icon': Icons.tv, 'color': Colors.blueAccent},
      {'name': 'Social', 'icon': Icons.people, 'color': Colors.greenAccent},
      {
        'name': 'Anxiety',
        'icon': Icons.psychology,
        'color': Colors.purpleAccent,
      },
      {'name': 'Urge', 'icon': Icons.water_drop, 'color': Colors.redAccent},
      {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey},
    ];

    showDialog(
      context: context,
      builder: (confirmContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AlertDialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: const Text("What was the trigger?"),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: triggers.length,
                  itemBuilder: (context, index) {
                    final t = triggers[index];
                    final isSel = selectedTrigger == t['name'];
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => selectedTrigger = t['name']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSel
                              ? t['color']
                              : (isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? Colors.white38 : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              t['icon'],
                              color: isSel ? Colors.white : t['color'],
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t['name'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSel
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(confirmContext),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: selectedTrigger == null
                      ? null
                      : () async {
                          Navigator.pop(confirmContext);
                          await Provider.of<HabitProvider>(
                            context,
                            listen: false,
                          ).resetHabit(habit.id, trigger: selectedTrigger!);
                        },
                  child: const Text(
                    "RESET CLOCK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
