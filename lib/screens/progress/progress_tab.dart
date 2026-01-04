import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';

// --- WIDGET IMPORTS ---
import 'widgets/daily_pledge_card.dart';
import 'widgets/mood_history_graph.dart';
import 'widgets/mood_history_list.dart';
import 'widgets/progress_calendar.dart';
import 'widgets/vulnerability_analysis.dart';
import 'widgets/animated_orb_background.dart';
import 'widgets/milestone_timeline.dart';
import 'package:my_auth_project/screens/progress/widgets/stats_box.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  Timer? _ticker;
  int _selectedView = 0; // 0 = Overview, 1 = Insights, 2 = Journey

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatLiveStreak(Duration diff) {
    if (diff.inDays > 0) {
      return "${diff.inDays}d ${diff.inHours % 24}h ${diff.inMinutes % 60}m";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours}h ${diff.inMinutes % 60}m";
    }
    return "${diff.inMinutes}m ${diff.inSeconds % 60}s";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final currentHabit = habitProvider.selectedHabit;

        if (habitProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (currentHabit == null) {
          return const Scaffold(
            body: Center(child: Text("No habit selected.")),
          );
        }

        final Duration diff = DateTime.now().difference(currentHabit.startDate);

        // Calculate longest streak for display
        final int currentStreakDays = diff.inDays;
        final int displayLongest =
            (currentStreakDays > currentHabit.longestStreak)
            ? currentStreakDays
            : currentHabit.longestStreak;

        return Scaffold(
          body: Stack(
            children: [
              AnimatedOrbBackground(isDark: isDark),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // --- HEADER ---
                      _buildHeader(currentHabit.title, isDark),
                      const SizedBox(height: 24),

                      // --- TOGGLE VIEW (3 TABS) ---
                      _buildSegmentedControl(isDark),
                      const SizedBox(height: 24),

                      // === VIEW 1: OVERVIEW ===
                      if (_selectedView == 0) ...[
                        const DailyPledgeCard(),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            StatBox(
                              label: "Current Streak",
                              value: _formatLiveStreak(diff),
                              accent: const Color(0xFF3B82F6),
                              isDark: isDark,
                              icon: PhosphorIcons.timer(),
                            ),
                            const SizedBox(width: 16),
                            StatBox(
                              label: "Longest Streak",
                              value: "$displayLongest days",
                              accent: Colors.orangeAccent,
                              isDark: isDark,
                              icon: PhosphorIcons.trophy(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        ProgressCalendar(
                          selectedHabit: currentHabit,
                          isDark: isDark,
                        ),
                      ]
                      // === VIEW 2: INSIGHTS ===
                      else if (_selectedView == 1) ...[
                        StatBox(
                          label: "Total Relapses",
                          value: "${currentHabit.totalRelapses}",
                          accent: Colors.redAccent,
                          isDark: isDark,
                          isWide: true,
                          icon: PhosphorIcons.warning(),
                        ),
                        const SizedBox(height: 32),

                        _buildSectionHeader(
                          "Vulnerability Analysis",
                          PhosphorIcons.shieldWarning(),
                          isDark,
                        ),
                        const SizedBox(height: 16),

                        VulnerabilityAnalysis(
                          stats: currentHabit.triggerStats,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 32),
                        const MoodHistoryGraph(),

                        const SizedBox(height: 32),
                        const MoodHistoryList(),
                      ]
                      // === VIEW 3: JOURNEY (MILESTONES) ===
                      else ...[
                        Center(
                          child: Text(
                            "ROAD TO RECOVERY",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const MilestoneTimeline(),
                      ],

                      const SizedBox(height: 80),
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

  // --- WIDGET HELPERS ---

  Widget _buildHeader(String habitTitle, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Progress",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              PhosphorIcons.target(),
              size: 16,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              habitTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? Colors.blueAccent : Colors.blueGrey,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildSegmentButton("Overview", 0, isDark),
          _buildSegmentButton("Insights", 1, isDark),
          _buildSegmentButton("Journey", 2, isDark), // New Tab
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String text, int index, bool isDark) {
    final isSelected = _selectedView == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedView = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF3B82F6) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13, // Slightly smaller to fit 3 items
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.white54 : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
}
