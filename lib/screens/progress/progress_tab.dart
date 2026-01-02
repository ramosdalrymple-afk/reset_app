import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  Timer? _ticker;
  late Stream<DocumentSnapshot> _userStream;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots();

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });

    // Background animation: slow breathing/drifting cycle
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

  // NEW: Floating Orb Mesh Background
  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            // Orb 1: Top Right drifting left
            Positioned(
              top: -100 + (100 * _bgController.value),
              right: -50 + (50 * _bgController.value),
              child: _buildOrb(
                300,
                Colors.blue.withOpacity(isDark ? 0.08 : 0.12),
              ),
            ),
            // Orb 2: Bottom Left drifting right
            Positioned(
              bottom: -50 + (80 * (1 - _bgController.value)),
              left: -100 + (100 * _bgController.value),
              child: _buildOrb(
                400,
                Colors.teal.withOpacity(isDark ? 0.05 : 0.1),
              ),
            ),
            // Orb 3: Middle drifting slightly
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

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(isDark),
          StreamBuilder<DocumentSnapshot>(
            stream: _userStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists)
                return const Center(child: Text("No data found."));

              final data = snapshot.data!.data() as Map<String, dynamic>;
              DateTime startDate = DateTime.parse(
                data['startDate'] ?? DateTime.now().toIso8601String(),
              );
              final Duration diff = DateTime.now().difference(startDate);

              int currentDays = diff.inDays;
              int storedLongest = data['longestStreak'] ?? 0;

              if (currentDays > storedLongest) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.id)
                    .update({'longestStreak': currentDays});
                storedLongest = currentDays;
              }

              final int totalRelapses = data['totalRelapses'] ?? 0;
              final Map<String, dynamic> history = data['history'] ?? {};

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
                      Text(
                        "My Progress",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -1,
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
                      const SizedBox(height: 50),
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
