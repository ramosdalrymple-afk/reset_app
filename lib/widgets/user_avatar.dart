import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserAvatar extends StatelessWidget {
  final String? photoURL;
  // 🟢 ADD THIS: Accept the name so we can show initials
  final String? userName;
  final bool isDark;
  final VoidCallback? onTap;
  final double radius;

  const UserAvatar({
    super.key,
    required this.photoURL,
    this.userName, // 🟢 ADD THIS
    required this.isDark,
    this.onTap,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    // Helper to safely get the first letter
    String getInitial() {
      if (userName == null || userName!.isEmpty) return "?";
      return userName![0].toUpperCase();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: photoURL != null
              ? Colors.transparent
              // 🟢 Fallback Color (Blue) if no photo
              : const Color(0xFF6366F1),
          backgroundImage: photoURL != null ? NetworkImage(photoURL!) : null,
          child: photoURL == null
              // 🟢 Show Initial instead of Icon if no photo
              ? Text(
                  getInitial(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.8,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
