import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;

  const AnimatedBackground({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            Positioned(
              top: -100 + (50 * controller.value),
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.blue.withOpacity(0.05)
                      : Colors.blue.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 100 - (50 * controller.value),
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.purple.withOpacity(0.05)
                      : Colors.purple.withOpacity(0.1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
