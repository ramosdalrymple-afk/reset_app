import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SupportButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SupportButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // We replace ElevatedButton with InkWell + Container
    // to match the exact structure of the Stress Poppers button.
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity, // Ensures it fills the Expanded parent
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFE11D48),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE11D48).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.lifebuoy(PhosphorIconsStyle.fill),
              size: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              "Urge Assistance",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
