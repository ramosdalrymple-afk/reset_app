import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'daily_check_in_sheet.dart'; // Import the new sheet

class DailyPledgeCard extends StatelessWidget {
  const DailyPledgeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final isPledged = habitProvider.isPledgedToday;
    final habit = habitProvider.selectedHabit;

    if (habit == null) return const SizedBox();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isPledged
                ? (isDark
                      ? Colors.green.withOpacity(0.1)
                      : Colors.green.withOpacity(0.05))
                : (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPledged
                  ? Colors.greenAccent.withOpacity(0.5)
                  : (isDark ? Colors.white10 : Colors.black12),
              width: isPledged ? 1.5 : 1,
            ),
            boxShadow: isPledged
                ? [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DAILY PLEDGE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: isPledged ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPledged ? "Commitment Active" : "Commit to Today",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPledged ? Colors.green : Colors.blueAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isPledged ? Colors.green : Colors.blueAccent)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPledged ? Icons.check_rounded : Icons.handshake_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!isPledged) ...[
                Text(
                  "I promise to stay clean from ${habit.title} for the next 24 hours.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // SHOW THE CHECK-IN SHEET
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DailyCheckInSheet(
                          onSubmit: (mood, note) {
                            habitProvider.takeDailyPledge(habit.id, mood, note);
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "I PLEDGE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  "You have made your promise for today. Stay strong!",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
