import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/wisdom_service.dart';
import 'dart:ui'; // For blur effect

class JarOfWisdom extends StatefulWidget {
  const JarOfWisdom({super.key});

  @override
  State<JarOfWisdom> createState() => _JarOfWisdomState();
}

class _JarOfWisdomState extends State<JarOfWisdom>
    with TickerProviderStateMixin {
  final WisdomService _service = WisdomService();
  bool _isShaking = false;

  void _handleTap() async {
    if (_isShaking) return;

    setState(() => _isShaking = true);

    // 1. Wait for animation & data
    final minDelay = Future.delayed(const Duration(milliseconds: 1500));
    final dataFetch = _service.shakeTheJar();

    final result = await Future.wait([dataFetch, minDelay]);
    final wisdom = result[0] as WisdomItem;

    if (mounted) {
      setState(() => _isShaking = false);
      // 2. Show the Modal
      _showWisdomDialog(wisdom);
    }
  }

  void _showWisdomDialog(WisdomItem item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.black.withOpacity(0.6), // Darken background
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(child: WisdomPopupCard(item: item));
      },
      transitionBuilder: (context, anim1, anim2, child) {
        // Pop-up animation: Scale + Fade
        return Transform.scale(
          scale: CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutBack,
          ).value,
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(onTap: _handleTap, child: _buildJarVisual()),
        const SizedBox(height: 16),
        if (_isShaking)
          Text(
            "Consulting the archives...",
            style: TextStyle(
              color: Colors.blueAccent.withOpacity(0.8),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ).animate(onPlay: (c) => c.repeat()).fade()
        else
          Text(
            "Tap to reveal wisdom",
            style: TextStyle(
              color: Colors.grey.withOpacity(0.6),
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ).animate().fade().slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildJarVisual() {
    // Glassmorphic Jar
    Widget jar = Container(
      width: 120,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // "Liquid" or "Tablets" inside
          Positioned(
            bottom: 10,
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Icon(
            PhosphorIcons.scroll(), // FIXED: Added ()
            size: 50,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );

    if (_isShaking) {
      return jar
          .animate(onPlay: (controller) => controller.repeat())
          .shake(
            hz: 8,
            rotation: 0.08,
            curve: Curves.easeInOut,
          ); // Slower, heavier shake
    }
    return jar;
  }
}

// --- NEW SEPARATE WIDGET FOR THE POPUP CARD ---
class WisdomPopupCard extends StatefulWidget {
  final WisdomItem item;
  const WisdomPopupCard({super.key, required this.item});

  @override
  State<WisdomPopupCard> createState() => _WisdomPopupCardState();
}

class _WisdomPopupCardState extends State<WisdomPopupCard> {
  bool _isSaved = false;

  void _saveToFavorites() async {
    // 1. If already saved, just alert the user and return
    if (_isSaved) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Already saved to your Wisdom Room"),
          backgroundColor: Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) return;

    // 2. Optimistic UI update (turn heart red immediately)
    setState(() => _isSaved = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_wisdom')
          .add({
            'text': widget.item.text,
            'source': widget.item.source,
            'type': widget.item.type,
            'savedAt': FieldValue.serverTimestamp(),
          });

      // 3. Show Success Alert
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                const Text("Saved to Wisdom Room"),
              ],
            ),
            backgroundColor: Colors.teal, // Sober/Calming Green
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Revert if error
      if (mounted) setState(() => _isSaved = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB), // Warm paper color
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.orange.withOpacity(0.1), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Icon(PhosphorIcons.quotes(), size: 32, color: Colors.amber[800]),
            const SizedBox(height: 20),

            // Quote Text
            Text(
              widget.item.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                height: 1.4,
                fontFamily: 'Georgia',
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            Divider(color: Colors.brown.withOpacity(0.1), thickness: 1),
            const SizedBox(height: 16),

            // Author & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "― ${widget.item.source}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                Row(
                  children: [
                    // Save Button
                    IconButton(
                      onPressed: _saveToFavorites,
                      icon: Icon(
                        _isSaved
                            ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                            : PhosphorIcons.heart(),
                        color: _isSaved ? Colors.redAccent : Colors.brown[300],
                      ),
                      tooltip: "Save to Archive",
                    ),
                    // Close Button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        PhosphorIcons.xCircle(),
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Optional: Small text indicator below icons for extra clarity
            if (_isSaved)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Saved",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.redAccent.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade().slideY(begin: 0.5, end: 0),
              ),
          ],
        ),
      ),
    );
  }
}
