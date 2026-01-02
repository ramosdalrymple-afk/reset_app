import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

// Added SingleTickerProviderStateMixin for the background animation controller
class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  bool _isExiting = false;
  late AnimationController _bgController; // Controller for background pulse

  final List<String> _phrases = [
    "This feeling will pass.",
    "Breathe in...",
    "Breathe out...",
    "You are stronger than this moment.",
    "One minute at a time.",
  ];

  late Stream<int> _phraseStream;

  @override
  void initState() {
    super.initState();
    // Initialize background animation: A slow, calming 8-second breathe cycle
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Cycle through phrases every 4 seconds
    _phraseStream = Stream.periodic(
      const Duration(seconds: 4),
      (i) => (i + 1) % _phrases.length,
    );
  }

  @override
  void dispose() {
    _bgController.dispose(); // Clean up controller
    super.dispose();
  }

  void _handleExit() {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    // Give the UI a split second to catch up before popping to prevent visual glitches
    Future.delayed(Duration.zero, () {
      if (mounted) Navigator.pop(context);
    });
  }

  // NEW: The Uniform "Breathing" Background
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            // A radial gradient that slowly expands and contracts
            gradient: RadialGradient(
              center: Alignment.center,
              // The radius pulses between 0.6 and 1.1 of screen width
              radius: 0.6 + (_bgController.value * 0.5),
              colors: [
                // A soft, calming blue in the center that fades in and out subtly
                const Color(
                  0xFF4F46E5,
                ).withOpacity(0.1 + (0.1 * _bgController.value)),
                // The base dark background color at the edges
                const Color(0xFF020817),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop && !_isExiting) {
          // Ensure we mark as exiting if system back button is used
          setState(() => _isExiting = true);
        }
      },
      child: Scaffold(
        // Background color is now handled by the animated container
        backgroundColor: const Color(0xFF020817),
        body: Stack(
          children: [
            // 1. The new animated background layer goes first (at the bottom)
            Positioned.fill(child: _buildAnimatedBackground()),

            // 2. The main content layer goes on top
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // LOTTIE ANIMATION
                    Lottie.asset(
                      'assets/animations/Sloth meditate.json',
                      width: 280,
                      height: 280,
                      repeat: true,
                      // Adding a subtle shadow to make the sloth pop off the glowing background
                      frameBuilder: (context, child, composition) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: -10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // PHRASE TEXT SECTION
                    StreamBuilder<int>(
                      stream: _phraseStream,
                      initialData: 0,
                      builder: (context, snapshot) {
                        return SizedBox(
                          height: 80,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 800),
                              child: Text(
                                _phrases[snapshot.data ?? 0],
                                key: ValueKey<int>(snapshot.data ?? 0),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 3),

                    // EXIT BUTTON
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: OutlinedButton(
                        onPressed: _handleExit,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white54,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          backgroundColor:
                              Colors.black12, // Subtle background for contrast
                        ),
                        child: const Text("I'M OKAY NOW"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
