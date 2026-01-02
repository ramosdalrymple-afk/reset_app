import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // NEW IMPORT
import 'package:firebase_auth/firebase_auth.dart';
// Import your Provider and Widgets
import '../../services/habit_provider.dart';
import './widgets/habit_step.dart';
import './widgets/date_step.dart';
import './widgets/motivation_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  // Controllers to capture user input
  final TextEditingController _habitController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  int _currentPage = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _habitController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  // UPDATED: Logic to use HabitProvider
  void _finishOnboarding() async {
    // 1. Validation
    if (_habitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select or enter what you're quitting"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 2. Use the Provider to add the habit to the subcollection
      // This will automatically create the document at users/{uid}/habits/{new_id}
      await Provider.of<HabitProvider>(context, listen: false).addHabit(
        _habitController.text.trim(),
        _selectedDate,
        _motivationController.text.trim(),
      );

      // 3. Success!
      // We don't need to manually navigate.
      // The AuthWrapper is listening to the HabitProvider.
      // Once the habit is added, AuthWrapper sees (habits.isNotEmpty) and switches to Navbar automatically.
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error creating habit: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Progress Indicator ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? Colors.white
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Main Step Content ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: PageView(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable swipe to force button use
                    onPageChanged: (int page) =>
                        setState(() => _currentPage = page),
                    children: [
                      HabitStep(controller: _habitController),
                      DateStep(
                        selectedDate: _selectedDate,
                        onDateChanged: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
                      ),
                      MotivationStep(controller: _motivationController),
                    ],
                  ),
                ),
              ),

              // --- Footer Buttons ---
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BACK BUTTON
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              ),
              child: const Text(
                "BACK",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          else
            const SizedBox(width: 60), // Spacer to keep layout balanced
          // NEXT / RESET BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0D47A1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _isSaving
                ? null
                : (_currentPage == 2
                      ? _finishOnboarding
                      : () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        )),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _currentPage == 2 ? "START JOURNEY" : "NEXT",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
