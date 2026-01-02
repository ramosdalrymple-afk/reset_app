import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({super.key});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final titleController = TextEditingController();
  final motivationController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? selectedHabitName;
  bool isLoading = false;

  final List<Map<String, dynamic>> commonHabits = [
    {'name': 'Alcohol', 'icon': Icons.local_bar},
    {'name': 'Smoking', 'icon': Icons.smoke_free},
    {'name': 'Vaping', 'icon': Icons.vape_free},
    {'name': 'Social Media', 'icon': Icons.phone_iphone},
    {'name': 'Gaming', 'icon': Icons.sports_esports},
    {'name': 'Sugar', 'icon': Icons.cake},
    {'name': 'Caffeine', 'icon': Icons.coffee},
    {'name': 'Porn', 'icon': Icons.lock_outline},
    {'name': 'Gambling', 'icon': Icons.casino},
    {'name': 'Custom', 'icon': Icons.edit},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "What are you quitting?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GRID
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: commonHabits.length,
                      itemBuilder: (context, index) {
                        final habit = commonHabits[index];
                        final isSelected = selectedHabitName == habit['name'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedHabitName = habit['name'];
                              if (habit['name'] != 'Custom') {
                                titleController.text = habit['name'];
                              } else {
                                titleController.clear();
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : (isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  habit['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  habit['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    // DETAILS FORM
                    if (selectedHabitName != null) ...[
                      // Title
                      TextField(
                        controller: titleController,
                        decoration: _inputDecoration(
                          "Habit Name",
                          isDark,
                          Icons.edit_outlined,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Motivation
                      TextField(
                        controller: motivationController,
                        maxLines: 2,
                        decoration: _inputDecoration(
                          "My 'Why'",
                          isDark,
                          Icons.favorite_border,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Date Picker
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 10),
                                Text("Start Date"),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                }
                              },
                              child: Text(
                                "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "START JOURNEY",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, size: 20),
    );
  }

  Future<void> _submit() async {
    if (titleController.text.isEmpty) return;

    setState(() => isLoading = true);

    await Provider.of<HabitProvider>(context, listen: false).addHabit(
      titleController.text.trim(),
      selectedDate,
      motivationController.text.trim(),
    );

    if (mounted) Navigator.pop(context);
  }
}
