import 'package:flutter/material.dart';

class HabitOption {
  final String name;
  final IconData icon;
  final Color color;
  HabitOption({required this.name, required this.icon, required this.color});
}

final List<HabitOption> predefinedHabits = [
  HabitOption(
    name: "Masturbation",
    icon: Icons.front_hand,
    color: Colors.purpleAccent,
  ),
  HabitOption(
    name: "Alcohol",
    icon: Icons.local_bar,
    color: Colors.orangeAccent,
  ),
  HabitOption(name: "Smoking", icon: Icons.smoke_free, color: Colors.blueGrey),
  HabitOption(
    name: "Social Media",
    icon: Icons.phone_android,
    color: Colors.blueAccent,
  ),
  HabitOption(
    name: "Gaming",
    icon: Icons.sports_esports,
    color: Colors.greenAccent,
  ),
  HabitOption(
    name: "Nicotine",
    icon: Icons.vape_free,
    color: Colors.tealAccent,
  ),
  HabitOption(name: "Sugar", icon: Icons.cake, color: Colors.pinkAccent),
  HabitOption(name: "Caffeine", icon: Icons.coffee, color: Colors.brown),
  HabitOption(name: "Porn", icon: Icons.lock_outline, color: Colors.redAccent),
  HabitOption(name: "Other", icon: Icons.add, color: Colors.indigoAccent),
];

class HabitStep extends StatefulWidget {
  final TextEditingController controller;
  const HabitStep({super.key, required this.controller});

  @override
  State<HabitStep> createState() => _HabitStepState();
}

class _HabitStepState extends State<HabitStep> {
  String? selectedHabit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
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
        const SizedBox(height: 25),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: predefinedHabits.length,
            itemBuilder: (context, index) {
              final habit = predefinedHabits[index];
              final isSelected = selectedHabit == habit.name;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedHabit = habit.name;
                    widget.controller.text = habit.name == "Other"
                        ? ""
                        : habit.name;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? habit.color
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? Colors.white38 : Colors.white12,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: habit.color.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        habit.icon,
                        size: 32,
                        color: isSelected
                            ? Colors.white
                            : habit.color.withOpacity(0.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedHabit == "Other")
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter custom habit...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
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
