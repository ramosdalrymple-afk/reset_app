import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyCalendar extends StatelessWidget {
  final Map<String, dynamic> history;
  final bool isDark;

  const WeeklyCalendar({
    super.key,
    required this.history,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Generate the last 7 days including today
    final today = DateTime.now();
    final weekDates = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Last 7 Days",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: isDark ? Colors.white30 : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDates.map((date) {
              return _buildDayBubble(date);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayBubble(DateTime date) {
    // 1. Format date key to match Firebase (YYYY-MM-DD)
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);

    // 2. Get Status
    final String? status = history[dateKey];

    // 3. Determine Aesthetics
    Color bgColor;
    Color textColor;
    Border? border;

    // Check if it's today
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;

    if (status == 'clean') {
      bgColor = const Color(0xFF2DD4BF); // Teal for success
      textColor = Colors.white;
    } else if (status == 'relapse') {
      bgColor = Colors.redAccent.withOpacity(0.8);
      textColor = Colors.white;
    } else {
      // No record (Gray)
      bgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!;
      textColor = isDark ? Colors.white38 : Colors.grey;
      if (isToday) {
        border = Border.all(
          color: Colors.blueAccent,
          width: 2,
        ); // Highlight today
      }
    }

    return Column(
      children: [
        // Day Name (Mon, Tue)
        Text(
          DateFormat('E').format(date)[0], // First letter only (M, T, W...)
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        // The Bubble
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: border,
          ),
          child: Center(
            child: status == 'clean'
                ? const Icon(Icons.check, size: 20, color: Colors.white)
                : status == 'relapse'
                ? const Icon(Icons.close, size: 20, color: Colors.white)
                : Text(
                    "${date.day}",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
