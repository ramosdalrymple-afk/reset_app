import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final bool isDark;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.user,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          radius: 18,
          backgroundColor: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey[200],
          backgroundImage: user?.photoURL != null
              ? NetworkImage(user!.photoURL!)
              : null,
          child: user?.photoURL == null
              ? Icon(
                  PhosphorIcons.user(), // Correct functional syntax
                  size: 20,
                  color: isDark ? Colors.white70 : Colors.black54,
                )
              : null,
        ),
      ),
    );
  }
}
