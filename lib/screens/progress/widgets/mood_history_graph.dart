import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/services/theme_provider.dart';

class MoodHistoryGraph extends StatelessWidget {
  const MoodHistoryGraph({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final habit = habitProvider.selectedHabit;

    if (habit == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      // reuse the stream we made earlier
      stream: habitProvider.getPledgeHistoryStream(habit.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final docs = snapshot.data!.docs;

        // 1. PREPARE DATA
        // We want the entries sorted by Date (Oldest -> Newest) for the graph
        // The stream gives us Newest -> Oldest, so we take the top 15 and reverse them.
        final List<QueryDocumentSnapshot> recentDocs = docs
            .take(15)
            .toList()
            .reversed
            .toList();

        if (recentDocs.length < 2) {
          // Not enough data for a line graph
          return _buildPlaceholder(isDark);
        }

        // Map data to chart points
        List<FlSpot> spots = [];
        for (int i = 0; i < recentDocs.length; i++) {
          final data = recentDocs[i].data() as Map<String, dynamic>;
          final String mood = data['mood'] ?? 'Okay';
          final double yVal = _getMoodValue(mood);
          spots.add(FlSpot(i.toDouble(), yVal));
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mood History",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "A look at your mood over the last ${recentDocs.length} check-ins.",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // 2. THE CHART
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDark ? Colors.white10 : Colors.grey[200],
                          strokeWidth: 1,
                          dashArray: [5, 5], // Dashed lines
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      // Y-AXIS LABELS (Custom Text)
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                _getMoodLabel(value),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ),

                      // X-AXIS LABELS (Dates)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < recentDocs.length) {
                              // Only show date every 2 or 3 points to avoid crowding
                              if (recentDocs.length > 7 && index % 2 != 0) {
                                return const SizedBox();
                              }

                              final data =
                                  recentDocs[index].data()
                                      as Map<String, dynamic>;
                              final date = (data['date'] as Timestamp).toDate();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('MMM d').format(date),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (recentDocs.length - 1).toDouble(),
                    minY: 1,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true, // Smooth curve
                        curveSmoothness: 0.35,
                        color: Colors.lightBlueAccent, // The line color
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.lightBlueAccent,
                              strokeWidth: 2,
                              strokeColor: isDark ? Colors.black : Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.lightBlueAccent.withOpacity(0.3),
                              Colors.lightBlueAccent.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
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

  // --- HELPER 1: Convert Mood String to Number (Y-Axis) ---
  double _getMoodValue(String mood) {
    switch (mood) {
      case 'Great':
        return 5;
      case 'Good':
        return 4;
      case 'Okay':
        return 3;
      case 'Bad':
        return 2;
      case 'Awful':
        return 1;
      default:
        return 3;
    }
  }

  // --- HELPER 2: Convert Number back to Label (Y-Axis) ---
  String _getMoodLabel(double value) {
    switch (value.toInt()) {
      case 5:
        return 'Great';
      case 4:
        return 'Good';
      case 3:
        return 'Okay';
      case 2:
        return 'Bad';
      case 1:
        return 'Awful';
      default:
        return '';
    }
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Center(
        child: Text(
          "Check in at least twice to see your mood graph.",
          style: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}
