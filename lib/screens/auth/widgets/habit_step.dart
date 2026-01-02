import 'package:flutter/material.dart';

class HabitOption {
  final String name;
  final IconData icon;
  HabitOption({required this.name, required this.icon});
}

// Updated list with Masturbation at the start
final List<HabitOption> predefinedHabits = [
  HabitOption(name: "Masturbation", icon: Icons.front_hand), // Or Icons.block
  HabitOption(name: "Alcohol", icon: Icons.local_bar),
  HabitOption(name: "Smoking", icon: Icons.smoke_free),
  HabitOption(name: "Social Media", icon: Icons.phone_android),
  HabitOption(name: "Gaming", icon: Icons.sports_esports),
  HabitOption(name: "Nicotine", icon: Icons.vape_free),
  HabitOption(name: "Sugar", icon: Icons.cake),
  HabitOption(name: "Caffeine", icon: Icons.coffee),
  HabitOption(name: "Porn", icon: Icons.phone_android),
  HabitOption(name: "Other", icon: Icons.add),
];

class HabitStep extends StatefulWidget {
  final TextEditingController controller;

  const HabitStep({super.key, required this.controller});

  @override
  State<HabitStep> createState() => _HabitStepState();
}

class _HabitStepState extends State<HabitStep> {
  String? selectedHabit;
  bool isCustom = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "What are you quitting?",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Choose your path to a better you",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.builder(
            // Use BouncingScrollPhysics to make it feel more "modern" on iOS and Android
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
            ),
            itemCount: predefinedHabits.length,
            itemBuilder: (context, index) {
              final habit = predefinedHabits[index];
              final isSelected = selectedHabit == habit.name;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedHabit = habit.name;
                    if (habit.name == "Other") {
                      isCustom = true;
                      widget.controller.clear();
                    } else {
                      isCustom = false;
                      widget.controller.text = habit.name;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white10,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        habit.icon,
                        size: 36,
                        color: isSelected
                            ? const Color(0xFF0D47A1)
                            : Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          habit.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF0D47A1)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (isCustom)
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter custom habit...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
