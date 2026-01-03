import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'package:url_launcher/url_launcher.dart'; // Uncomment for real calling

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  bool _isExiting = false;

  // Modes: 0 = Breathing (Default), 1 = Grounding (5-4-3-2-1)
  int _currentMode = 0;

  // BACKGROUND ANIMATION
  late AnimationController _bgController;

  // BREATHING LOGIC
  late AnimationController _breathingTextController;
  String _breathingText = "Inhale...";

  // GROUNDING LOGIC
  int _groundingStep = 5;
  final Map<int, String> _groundingInstructions = {
    5: "Look around.\nFind 5 things you can see.",
    4: "Reach out.\nFind 4 things you can touch.",
    3: "Listen closely.\nFind 3 things you can hear.",
    2: "Breathe deep.\nFind 2 things you can smell.",
    1: "Focus inward.\nFind 1 thing you can taste\nor one good thing about yourself.",
  };

  @override
  void initState() {
    super.initState();

    // 1. Background Pulse
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 2. Breathing Text
    _breathingTextController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingTextController.addListener(() {
      if (_currentMode == 0) {
        if (_breathingTextController.status == AnimationStatus.forward) {
          if (_breathingText != "Inhale...") {
            setState(() => _breathingText = "Inhale...");
          }
        } else {
          if (_breathingText != "Exhale...") {
            setState(() => _breathingText = "Exhale...");
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _breathingTextController.dispose();
    super.dispose();
  }

  void _handleExit() {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    Future.delayed(Duration.zero, () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _nextGroundingStep() {
    setState(() {
      if (_groundingStep > 1) {
        _groundingStep--;
      } else {
        _groundingStep = 5;
        _currentMode = 0; // Go back to breathing
      }
    });
  }

  // --- UPDATED FOR PHILIPPINES / PANGASINAN ---
  void _showHelpOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reach Out (Philippines)",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 1. NCMH Crisis Hotline (The main mental health line in PH)
            ListTile(
              leading: const Icon(
                Icons.phone_in_talk,
                color: Colors.greenAccent,
              ),
              title: const Text(
                "NCMH Crisis Hotline (1553)",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                "Luzon-wide toll-free landline",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                // launchUrl(Uri.parse("tel:1553"));
              },
            ),

            // 2. National Emergency
            ListTile(
              leading: const Icon(Icons.local_police, color: Colors.blueAccent),
              title: const Text(
                "Emergency Hotline (911)",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                "For immediate danger",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                // launchUrl(Uri.parse("tel:911"));
              },
            ),

            // 3. Trusted Friend
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.pinkAccent),
              title: const Text(
                "Call a Trusted Friend",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // You can add logic here to call a specific contact
              },
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.5 + (_bgController.value * 0.4),
              colors: [
                const Color(
                  0xFF4F46E5,
                ).withOpacity(0.15 + (0.15 * _bgController.value)),
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
        if (didPop && !_isExiting) setState(() => _isExiting = true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020817),
        body: Stack(
          children: [
            Positioned.fill(child: _buildAnimatedBackground()),
            SafeArea(
              child: SingleChildScrollView(
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                  child: Column(
                    children: [
                      // TOP BAR
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.support_agent,
                              color: Colors.white54,
                            ),
                            onPressed: _showHelpOptions,
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // SLOTH ANIMATION
                      Lottie.asset(
                        'assets/animations/Sloth meditate.json',
                        width: 250,
                        height: 250,
                        repeat: true,
                        frameBuilder: (context, child, composition) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 50,
                                  spreadRadius: -10,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // TEXT SECTION
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 140),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _currentMode == 0
                              ? Column(
                                  key: const ValueKey("Breathing"),
                                  children: [
                                    Text(
                                      _breathingText.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Follow the pulse.",
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  key: const ValueKey("Grounding"),
                                  children: [
                                    Text(
                                      "FIND $_groundingStep",
                                      style: const TextStyle(
                                        color: Color(0xFF4F46E5),
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Text(
                                        _groundingInstructions[_groundingStep]!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // TOGGLES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildToolChip("Breathe", 0, Icons.air),
                          const SizedBox(width: 12),
                          _buildToolChip("Ground Me", 1, Icons.landscape),
                        ],
                      ),

                      // ACTION BUTTON
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 30, 30, 40),
                        child: _currentMode == 0
                            ? OutlinedButton(
                                onPressed: _handleExit,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white54,
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text("I'M FEELING BETTER"),
                              )
                            : ElevatedButton(
                                onPressed: _nextGroundingStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text("NEXT STEP"),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolChip(String label, int index, IconData icon) {
    bool isSelected = _currentMode == index;
    return GestureDetector(
      onTap: () => setState(() => _currentMode = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white54 : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
