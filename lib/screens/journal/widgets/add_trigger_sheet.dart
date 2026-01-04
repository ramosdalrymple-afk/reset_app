import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';

class AddTriggerSheet extends StatefulWidget {
  final String habitId;
  final bool isDark;

  const AddTriggerSheet({
    super.key,
    required this.habitId,
    required this.isDark,
  });

  @override
  State<AddTriggerSheet> createState() => _AddTriggerSheetState();
}

class _AddTriggerSheetState extends State<AddTriggerSheet> {
  String _selectedTrigger = 'Stress';
  double _intensity = 5.0;
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _triggers = [
    {'name': 'Stress', 'icon': PhosphorIcons.lightning()},
    {'name': 'Boredom', 'icon': PhosphorIcons.television()},
    {'name': 'Social', 'icon': PhosphorIcons.usersThree()},
    {'name': 'Anxiety', 'icon': PhosphorIcons.brain()},
    {'name': 'Sadness', 'icon': PhosphorIcons.cloudRain()},
    {'name': 'Craving', 'icon': PhosphorIcons.fire()},
    {'name': 'Custom', 'icon': PhosphorIcons.plusCircle()}, // New Custom Option
  ];

  // Helper to handle Custom Trigger Input
  Future<void> _handleCustomTrigger() async {
    String customName = "";
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          "Custom Trigger",
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
          decoration: const InputDecoration(hintText: "Enter trigger name..."),
          onChanged: (val) => customName = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (customName.trim().isNotEmpty) {
                setState(() => _selectedTrigger = customName.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Log a Trigger",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "What triggered you?",
              style: TextStyle(
                color: widget.isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // --- GRID VIEW FOR TRIGGERS ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _triggers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 items per row
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9, // Adjust height vs width
              ),
              itemBuilder: (context, index) {
                final t = _triggers[index];
                final isSelected = _selectedTrigger == t['name'];

                return GestureDetector(
                  onTap: () {
                    if (t['name'] == 'Custom') {
                      _handleCustomTrigger();
                    } else {
                      setState(() => _selectedTrigger = t['name']);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blueAccent
                          : (widget.isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          t['icon'],
                          color: isSelected
                              ? Colors.white
                              : (widget.isDark
                                    ? Colors.white70
                                    : Colors.black54),
                          size: 22,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t['name'],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : (widget.isDark
                                      ? Colors.white70
                                      : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // --- INTENSITY SLIDER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Intensity",
                  style: TextStyle(
                    color: widget.isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  "${_intensity.toInt()}/10",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6.0,
                tickMarkShape: SliderTickMarkShape.noTickMark,
              ),
              child: Slider(
                value: _intensity,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (val) => setState(() => _intensity = val),
              ),
            ),

            const SizedBox(height: 12),

            // --- NOTES ---
            TextField(
              controller: _noteController,
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Add a note (optional)...",
                hintStyle: TextStyle(
                  color: widget.isDark ? Colors.white30 : Colors.grey,
                ),
                filled: true,
                fillColor: widget.isDark ? Colors.black26 : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- LOG BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Provider.of<HabitProvider>(
                    context,
                    listen: false,
                  ).logTrigger(
                    habitId: widget.habitId,
                    triggerName: _selectedTrigger,
                    intensity: _intensity.toInt(),
                    note: _noteController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Log Trigger",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
