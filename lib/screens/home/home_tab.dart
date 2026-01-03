import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_auth_project/widgets/global_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';

// Widgets
import 'widgets/animated_background.dart';
import 'widgets/time_bar.dart';
import 'widgets/quote_card.dart';
import 'widgets/action_buttons.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  Timer? _ticker;
  late AnimationController _bgController;

  final List<String> _dailyQuotes = [
    "One day at a time; this is enough. Do not look back.",
    "The secret of getting ahead is getting started.",
    "Recovery is a process, not an event.",
    "Your best days are ahead of you.",
    "Small progress is still progress. Keep going.",
    "Success is the sum of small efforts repeated daily.",
    "Believe you can and you're halfway there.",
  ];

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _bgController.dispose();
    super.dispose();
  }

  String _getQuote() {
    int dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return _dailyQuotes[dayOfYear % _dailyQuotes.length];
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
          // 1. Extend body behind app bar for full-screen animated background
          extendBodyBehindAppBar: true,
          // 2. Add the AppBar here so layout knows about it
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

    // Calculate Percentages
    double secPercent = (diff.inSeconds % 60) / 60.0;
    double minPercent = (diff.inMinutes % 60) / 60.0;
    double hourPercent = (diff.inHours % 24) / 24.0;
    double dayPercent = (diff.inDays % 30) / 30.0;

    // Logic Checks
    final now = DateTime.now();
    final String dateKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String? todayStatus = habit.history[dateKey];
    bool isAlreadyClean = todayStatus == 'clean';
    bool isStreakTooShort = diff.inSeconds < 30;

    return SafeArea(
      // 3. Keep top: true so we don't overlap the Notch/Status Bar
      // But we will manage the AppBar spacing manually below
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TOP SECTION
                    Column(
                      children: [
                        // 4. FIX: Use kToolbarHeight (56px) instead of 60.
                        // This pushes content just enough to clear the GlobalAppBar.
                        const SizedBox(height: kToolbarHeight),

                        _buildHeader(habit.title, isDark),

                        // 5. FIX: Reduced from 30 to 16 to tighten the UI
                        const SizedBox(height: 16),

                        TimeBar(
                          value: "${diff.inDays}",
                          label: "days",
                          color: const Color(0xFF2DD4BF),
                          percentage: dayPercent,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10), // Slightly reduced from 12
                        TimeBar(
                          value: "${diff.inHours % 24}",
                          label: "hours",
                          color: const Color(0xFF3B82F6),
                          percentage: hourPercent,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        TimeBar(
                          value: "${diff.inMinutes % 60}",
                          label: "minutes",
                          color: const Color(0xFF6366F1),
                          percentage: minPercent,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        TimeBar(
                          value: "${diff.inSeconds % 60}",
                          label: "seconds",
                          color: const Color(0xFF8B5CF6),
                          percentage: secPercent,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // BOTTOM SECTION
                    Column(
                      children: [
                        // 6. FIX: Reduced from 40 to 24
                        const SizedBox(height: 24),
                        QuoteCard(isDark: isDark, quote: _getQuote()),
                        const SizedBox(height: 24), // Reduced from 32
                        ActionButtons(
                          isAlreadyClean: isAlreadyClean,
                          isStreakTooShort: isStreakTooShort,
                          onCleanTap: () => _confirmClean(context, habit),
                          onRelapseTap: () => _confirmReset(context, habit),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- HELPER METHODS & DIALOGS (Kept exactly the same as your code) ---

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
    // ... [Previous logic for Reset Dialog kept same] ...
    // Note: I omitted the full body of _confirmReset to save space,
    // simply paste your previous _confirmReset logic here.
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    String? selectedTrigger;

    // (Paste your triggers list and showDialog code here)
    // ...
    // If you need me to paste the full reset dialog code again, let me know!
    // Just re-using the exact logic you provided in the prompt.

    // TEMPORARY PLACEHOLDER FOR THE DIALOG CODE YOU SENT:
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
