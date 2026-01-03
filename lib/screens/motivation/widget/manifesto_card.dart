import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Ensure this is in pubspec
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ManifestoCard extends StatelessWidget {
  final String text;
  final bool isDark;

  const ManifestoCard({super.key, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    final textColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final watermarkColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
        ), // Increased blur for premium feel
        child: Container(
          width: double.infinity,
          // Removed padding here to let the Stack work fully, added padding inside Column
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. BACKGROUND WATERMARK (The Quote Icon)
              Positioned(
                top: -10,
                left: -10,
                child: Icon(
                  PhosphorIcons.quotes(PhosphorIconsStyle.fill),
                  size: 100,
                  color: watermarkColor,
                ),
              ),

              // 2. CONTENT
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    // Header Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.fire(PhosphorIconsStyle.fill),
                          size: 14,
                          color: isDark ? Colors.orangeAccent : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "MY MAIN REASON",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white54 : Colors.black45,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // The User's Text (Hero)
                    Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22, // Larger size
                            height: 1.4,
                            fontFamily:
                                'Georgia', // Serif font feels more "written" and important
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                        .animate()
                        .fade(duration: 800.ms)
                        .shimmer(
                          delay: 400.ms,
                          duration: 1800.ms,
                          color: Colors.white.withOpacity(0.3),
                        ), // Subtle shimmer
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
