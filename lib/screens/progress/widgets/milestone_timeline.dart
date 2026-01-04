import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../models/milestone_data.dart';
import '../../../services/habit_provider.dart';
import '../../../services/theme_provider.dart';

class MilestoneTimeline extends StatelessWidget {
  const MilestoneTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final habit = provider.selectedHabit;
        if (habit == null) return const SizedBox();

        // Calculate Streak
        final streakDays = DateTime.now().difference(habit.startDate).inDays;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 16),
              child: Text(
                "YOUR JOURNEY",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),

            // Build the Timeline
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recoveryMilestones.length,
              itemBuilder: (context, index) {
                final milestone = recoveryMilestones[index];
                final isUnlocked = streakDays >= milestone.days;
                final isLast = index == recoveryMilestones.length - 1;

                // Calculate unlock date
                final unlockDate = habit.startDate.add(
                  Duration(days: milestone.days),
                );
                final dateString = DateFormat('MMM d, yyyy').format(unlockDate);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- COLUMN 1: THE LINE & DOT ---
                      SizedBox(
                        width: 40,
                        child: Column(
                          children: [
                            // Top Line
                            if (index != 0)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: isUnlocked
                                      ? Colors.blueAccent
                                      : (isDark
                                            ? Colors.white12
                                            : Colors.black12),
                                ),
                              ),

                            // The Icon/Dot
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? Colors.blueAccent
                                    : (isDark
                                          ? Colors.white10
                                          : Colors.grey[200]),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isUnlocked
                                      ? Colors.blueAccent
                                      : (isDark
                                            ? Colors.white24
                                            : Colors.black12),
                                  width: 2,
                                ),
                                boxShadow: isUnlocked
                                    ? [
                                        BoxShadow(
                                          color: Colors.blueAccent.withOpacity(
                                            0.4,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                milestone.icon,
                                size: 16,
                                color: isUnlocked
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white24
                                          : Colors.black26),
                              ),
                            ),

                            // Bottom Line
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  // Only color next line if NEXT milestone is unlocked
                                  color:
                                      (streakDays >=
                                          recoveryMilestones[index + 1].days)
                                      ? Colors.blueAccent
                                      : (isDark
                                            ? Colors.white12
                                            : Colors.black12),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // --- COLUMN 2: THE INTERACTIVE CONTENT ---
                      Expanded(
                        child: InkWell(
                          onTap: () => _showMilestoneDialog(
                            context,
                            milestone,
                            isUnlocked,
                            unlockDate,
                            streakDays,
                            isDark,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      milestone.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isUnlocked
                                            ? (isDark
                                                  ? Colors.white
                                                  : Colors.black)
                                            : (isDark
                                                  ? Colors.white38
                                                  : Colors.black38),
                                      ),
                                    ),
                                    if (isUnlocked)
                                      Icon(
                                        PhosphorIcons.checkCircle(
                                          PhosphorIconsStyle.fill,
                                        ),
                                        size: 16,
                                        color: Colors.greenAccent,
                                      )
                                    else
                                      Icon(
                                        PhosphorIcons.lockKey(),
                                        size: 14,
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.black26,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  milestone.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- THE MODAL POPUP ---
  void _showMilestoneDialog(
    BuildContext context,
    Milestone milestone,
    bool isUnlocked,
    DateTime date,
    int currentStreak,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final daysLeft = milestone.days - currentStreak;
        final dateString = DateFormat('MMMM d, yyyy').format(date);

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Large Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Colors.blueAccent.withOpacity(0.1)
                        : (isDark ? Colors.white10 : Colors.grey[100]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    milestone.icon,
                    size: 48,
                    color: isUnlocked
                        ? Colors.blueAccent
                        : (isDark ? Colors.white38 : Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Title
                Text(
                  milestone.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Subtitle / Description
                Text(
                  milestone.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Divider
                Divider(color: isDark ? Colors.white24 : Colors.grey[300]),
                const SizedBox(height: 16),

                // 5. Status Details
                if (isUnlocked) ...[
                  // UNLOCKED STATE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.calendarCheck(),
                        size: 18,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Achieved on $dateString",
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // LOCKED STATE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.clock(),
                        size: 18,
                        color: Colors.orangeAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$daysLeft days to go",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Target Date: $dateString",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // 6. Close Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
