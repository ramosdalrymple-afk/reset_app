import 'package:flutter/material.dart';

class AnimatedOrbBackground extends StatefulWidget {
  final bool isDark;
  const AnimatedOrbBackground({super.key, required this.isDark});

  @override
  State<AnimatedOrbBackground> createState() => _AnimatedOrbBackgroundState();
}

class _AnimatedOrbBackgroundState extends State<AnimatedOrbBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            Positioned(
              top: -100 + (100 * _bgController.value),
              right: -50 + (50 * _bgController.value),
              child: _buildOrb(
                300,
                Colors.blue.withOpacity(widget.isDark ? 0.08 : 0.12),
              ),
            ),
            Positioned(
              bottom: -50 + (80 * (1 - _bgController.value)),
              left: -100 + (100 * _bgController.value),
              child: _buildOrb(
                400,
                Colors.teal.withOpacity(widget.isDark ? 0.05 : 0.1),
              ),
            ),
            Positioned(
              top: 200 + (50 * _bgController.value),
              left: 150 - (30 * _bgController.value),
              child: _buildOrb(
                200,
                Colors.indigo.withOpacity(widget.isDark ? 0.04 : 0.08),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
