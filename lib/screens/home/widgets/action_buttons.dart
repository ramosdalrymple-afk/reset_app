import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActionButtons extends StatelessWidget {
  final bool isAlreadyClean;
  final bool isStreakTooShort;
  final VoidCallback onCleanTap;
  final VoidCallback onRelapseTap;

  const ActionButtons({
    super.key,
    required this.isAlreadyClean,
    required this.isStreakTooShort,
    required this.onCleanTap,
    required this.onRelapseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            isAlreadyClean ? "Done for Today" : "I'm Clean Today",
            isAlreadyClean
                ? Colors.grey.withOpacity(0.5)
                : const Color(0xFF2563EB),
            Icons.check_circle_outline,
            isAlreadyClean
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    onCleanTap();
                  },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            "I Relapsed",
            isStreakTooShort
                ? Colors.grey.withOpacity(0.5)
                : const Color(0xFF991B1B),
            Icons.history_rounded,
            isStreakTooShort
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    onRelapseTap();
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: onPressed == null ? 0 : 4,
        shadowColor: color.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
