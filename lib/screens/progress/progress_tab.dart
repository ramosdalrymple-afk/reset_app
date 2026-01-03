import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';

// --- IMPORTS ---
import 'widgets/daily_pledge_card.dart';
import 'widgets/mood_history_graph.dart';
import 'widgets/mood_history_list.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  Timer? _ticker;
  late AnimationController _bgController;

  // --- STATE FOR VIEW TOGGLE ---
  int _selectedView = 0; // 0 = Overview, 1 = Insights

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _bgController.dispose();
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

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            Positioned(
              top: -100 + (100 * _bgController.value),
              right: -50 + (50 * _bgController.value),
              child: _buildOrb(
                300,
                Colors.blue.withOpacity(isDark ? 0.08 : 0.12),
              ),
            ),
            Positioned(
              bottom: -50 + (80 * (1 - _bgController.value)),
              left: -100 + (100 * _bgController.value),
              child: _buildOrb(
                400,
                Colors.teal.withOpacity(isDark ? 0.05 : 0.1),
              ),
            ),
            Positioned(
              top: 200 + (50 * _bgController.value),
              left: 150 - (30 * _bgController.value),
              child: _buildOrb(
                200,
                Colors.indigo.withOpacity(isDark ? 0.04 : 0.08),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
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

        final DateTime startDate = currentHabit.startDate;
        final Duration diff = DateTime.now().difference(startDate);
        final int storedLongest = currentHabit.longestStreak;
        final int totalRelapses = currentHabit.totalRelapses;
        final Map<String, dynamic> history = currentHabit.history;
        final Map<String, int> triggerStats = currentHabit.triggerStats;

        return Scaffold(
          body: Stack(
            children: [
              _buildAnimatedBackground(isDark),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // --- HEADER ---
                      Column(
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
                              // FIX: Added () to call the function
                              Icon(
                                PhosphorIcons.target(),
                                size: 16,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                currentHabit.title.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- 1. TOGGLE VIEW ---
                      _buildSegmentedControl(isDark),
                      const SizedBox(height: 24),

                      // --- 2. SWITCH CONTENT ---
                      if (_selectedView == 0) ...[
                        // === OVERVIEW TAB ===
                        const DailyPledgeCard(),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            _buildStatBox(
                              "Current Streak",
                              _formatLiveStreak(diff),
                              const Color(0xFF3B82F6),
                              isDark,
                              // FIX: Added ()
                              icon: PhosphorIcons.timer(),
                            ),
                            const SizedBox(width: 16),
                            _buildStatBox(
                              "Longest Streak",
                              "$storedLongest days",
                              Colors.orangeAccent,
                              isDark,
                              // FIX: Added ()
                              icon: PhosphorIcons.trophy(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // FIX: Added ()
                        _buildSectionHeader(
                          "Calendar",
                          PhosphorIcons.calendarBlank(),
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildCalendarCard(history, isDark),
                      ] else ...[
                        // === INSIGHTS TAB ===
                        _buildStatBox(
                          "Total Relapses",
                          "$totalRelapses",
                          Colors.redAccent,
                          isDark,
                          isWide: true,
                          // FIX: Added ()
                          icon: PhosphorIcons.warning(),
                        ),
                        const SizedBox(height: 32),

                        // FIX: Added ()
                        _buildSectionHeader(
                          "Vulnerability Analysis",
                          PhosphorIcons.shieldWarning(),
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildTriggerAnalysis(triggerStats, isDark),

                        const SizedBox(height: 32),
                        const MoodHistoryGraph(),

                        const SizedBox(height: 32),
                        const MoodHistoryList(),
                      ],

                      const SizedBox(height: 80), // Extra bottom padding
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
              fontSize: 14,
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

  // --- TRIGGER ANALYSIS ---

  Widget _buildTriggerAnalysis(Map<String, int> stats, bool isDark) {
    if (stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          children: [
            // FIX: Added ()
            Icon(
              PhosphorIcons.checkCircle(),
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              "No relapse data available.",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Keep up the great work!",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sortedEntries.first.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: sortedEntries.map((entry) {
          final double percent = entry.value / maxCount;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      "${entry.value}",
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      height: 8,
                      width: MediaQuery.of(context).size.width * 0.7 * percent,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.cyanAccent],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- STAT BOX ---

  Widget _buildStatBox(
    String label,
    String value,
    Color accent,
    bool isDark, {
    bool isWide = false,
    IconData? icon,
  }) {
    return Expanded(
      flex: isWide ? 0 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: isWide ? double.infinity : null,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1.0,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (icon != null)
                      Icon(icon, size: 20, color: accent.withOpacity(0.7)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: value.length > 10 ? 18 : 24,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CALENDAR ---

  Widget _buildCalendarCard(Map<String, dynamic> history, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                onPageChanged: (focusedDay) =>
                    setState(() => _focusedDay = focusedDay),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  // FIX: Added ()
                  leftChevronIcon: Icon(
                    PhosphorIcons.caretLeft(),
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  rightChevronIcon: Icon(
                    PhosphorIcons.caretRight(),
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  prioritizedBuilder: (context, day, focusedDay) {
                    final String dateKey =
                        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                    if (history.containsKey(dateKey)) {
                      final status = history[dateKey];
                      return _buildCalendarDay(
                        day,
                        status == 'clean'
                            ? const Color(0xFF2DD4BF)
                            : Colors.red,
                        isDark,
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xFF2DD4BF), "Clean"),
        const SizedBox(width: 20),
        _legendItem(Colors.red, "Relapse"),
      ],
    );
  }

  Widget _legendItem(Color col, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: col, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
