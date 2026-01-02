import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';

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
    if (diff.inDays > 0)
      return "${diff.inDays}d ${diff.inHours % 24}h ${diff.inMinutes % 60}m";
    if (diff.inHours > 0)
      return "${diff.inHours}h ${diff.inMinutes % 60}m ${diff.inSeconds % 60}s";
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
          return const Center(child: CircularProgressIndicator());
        }
        if (currentHabit == null) {
          return const Center(child: Text("No habit selected."));
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Space for GlobalAppBar
                      const SizedBox(height: 60),

                      Text(
                        "My Progress",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        currentHabit.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          _buildStatBox(
                            "Current Streak",
                            _formatLiveStreak(diff),
                            const Color(0xFF3B82F6),
                            isDark,
                          ),
                          const SizedBox(width: 15),
                          _buildStatBox(
                            "Longest Streak",
                            "$storedLongest days",
                            Colors.orangeAccent,
                            isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildStatBox(
                        "Total Relapses",
                        "$totalRelapses",
                        Colors.redAccent,
                        isDark,
                        isWide: true,
                      ),
                      const SizedBox(height: 32),
                      _buildCalendarCard(history, isDark),
                      const SizedBox(height: 32),

                      // --- NEW VULNERABILITY SECTION ---
                      Text(
                        "Vulnerability Analysis",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTriggerAnalysis(triggerStats, isDark),

                      const SizedBox(height: 50),
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

  Widget _buildTriggerAnalysis(Map<String, int> stats, bool isDark) {
    if (stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "No relapse data yet. Stay strong!",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Sort stats by count descending
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sortedEntries.first.value;

    return Column(
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
                    "${entry.value} times",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
                      color: isDark ? Colors.white10 : Colors.black12,
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    Color accent,
    bool isDark, {
    bool isWide = false,
  }) {
    return Expanded(
      flex: isWide ? 0 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: isWide ? double.infinity : null,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: value.length > 10 ? 15 : 22,
                    fontWeight: FontWeight.bold,
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

  Widget _buildCalendarCard(Map<String, dynamic> history, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: isDark ? Colors.white : Colors.black54,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white : Colors.black54,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  outsideDaysVisible: false,
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
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
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
