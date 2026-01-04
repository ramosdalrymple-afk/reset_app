import 'dart:ui';
import 'package:flutter/material.dart';

class AmbientBackground extends StatefulWidget {
  final bool isDark;

  const AmbientBackground({super.key, required this.isDark});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(widget.isDark ? 0.15 : 0.2),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            // Base background color
            Container(color: Theme.of(context).scaffoldBackgroundColor),

            // Orb 1 (Top Left)
            Positioned(
              top: -100 + (50 * _bgController.value),
              left: -50,
              child: _buildOrb(
                300,
                widget.isDark ? Colors.purpleAccent : Colors.blueAccent,
              ),
            ),

            // Orb 2 (Bottom Right)
            Positioned(
              bottom: -100 + (50 * _bgController.value),
              right: -50,
              child: _buildOrb(
                300,
                widget.isDark ? Colors.tealAccent : Colors.cyanAccent,
              ),
            ),

            // Orb 3 (Middle Floating)
            Positioned(
              top: 300 + (100 * _bgController.value),
              left: -100 + (200 * _bgController.value),
              child: _buildOrb(
                250,
                widget.isDark ? Colors.indigoAccent : Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }
}
