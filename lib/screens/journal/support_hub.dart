import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';
import 'widgets/add_trigger_sheet.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final currentHabit = habitProvider.selectedHabit;

        if (currentHabit == null) {
          return const Center(child: Text("No habit selected"));
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SUPPORT HUB",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "You Are Not Alone",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: isDark
                            ? Colors.white10
                            : Colors.grey[200],
                        child: Icon(
                          PhosphorIcons.bell(),
                          color: isDark ? Colors.white : Colors.black,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 1: AI COMPANION (Placeholder) ---
                  _buildAiPeptalkCard(isDark),

                  const SizedBox(height: 32),

                  // --- SECTION 2: TRIGGER LOG (Minimized) ---
                  _buildTriggerSectionHeader(context, currentHabit.id, isDark),
                  const SizedBox(height: 16),
                  _buildCompactTriggerList(
                    habitProvider,
                    currentHabit.id,
                    isDark,
                    context, // Passing context for dialogs
                  ),

                  const SizedBox(height: 32),

                  // --- SECTION 3: COMMUNITY POSTS (Placeholder) ---
                  _buildCommunitySectionHeader(isDark),
                  const SizedBox(height: 16),
                  _buildCommunityPlaceholder(isDark),

                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildAiPeptalkCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo to Purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIconsFill.sparkle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "AI Coach",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Feeling the urge? Need a quick peptalk or strategy? I'm here to listen.",
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to AI Chat Screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Start Session",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerSectionHeader(
    BuildContext context,
    String habitId,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Struggles",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddTriggerSheet(habitId: habitId, isDark: isDark),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.plus(),
                  size: 14,
                  color: isDark ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 4),
                Text(
                  "Log",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- UPDATED LIST WITH SWIPE TO DELETE ---
  Widget _buildCompactTriggerList(
    HabitProvider provider,
    String habitId,
    bool isDark,
    BuildContext context,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: provider.getTriggerLogsStream(habitId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey[200]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.checkCircle(),
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  "No recent triggers. Keep it up!",
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final logs = snapshot.data!.docs.take(3).toList(); // ONLY SHOW LAST 3

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = logs[index];
            final data = doc.data() as Map<String, dynamic>;
            final intensity = data['intensity'] ?? 0;

            // --- DISMISSIBLE WRAPPER (SLIDE TO DELETE) ---
            return Dismissible(
              key: Key(doc.id), // Unique Key
              direction: DismissDirection.endToStart, // Swipe Right to Left
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  PhosphorIcons.trash(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              // Confirmation Dialog for Swipe
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    title: Text(
                      "Delete Entry?",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    content: Text(
                      "This will remove this trigger log permanently.",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              // Action when swipe is confirmed
              onDismissed: (direction) {
                provider.deleteTriggerLog(habitId, doc.id);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey[100]!,
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getColorForIntensity(intensity),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['triggerName'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (data['note'] != null && data['note'].isNotEmpty)
                            Text(
                              data['note'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      "$intensity/10",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _getColorForIntensity(intensity),
                      ),
                    ),
                    // --- BUTTON DELETE (Retained) ---
                    IconButton(
                      icon: Icon(
                        PhosphorIcons.trash(),
                        size: 18,
                        color: isDark ? Colors.white30 : Colors.grey[400],
                      ),
                      onPressed: () => _confirmDeleteLogButton(
                        context,
                        provider,
                        habitId,
                        doc.id,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- DELETE DIALOG FOR BUTTON (Void return) ---
  void _confirmDeleteLogButton(
    BuildContext context,
    HabitProvider provider,
    String habitId,
    String logId,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          "Delete Entry?",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          "This will remove this trigger log permanently.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTriggerLog(habitId, logId);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySectionHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Community Feed",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Icon(
          PhosphorIcons.caretRight(),
          color: isDark ? Colors.white54 : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildCommunityPlaceholder(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.usersThree(),
            size: 40,
            color: isDark ? Colors.white24 : Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            "Connect with others soon",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Share your journey, get advice, and celebrate milestones.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIntensity(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.orange;
    return Colors.redAccent;
  }
}
