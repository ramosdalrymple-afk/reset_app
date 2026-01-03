import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/wisdom_service.dart';

class JarOfWisdom extends StatefulWidget {
  const JarOfWisdom({super.key});

  @override
  State<JarOfWisdom> createState() => _JarOfWisdomState();
}

class _JarOfWisdomState extends State<JarOfWisdom>
    with TickerProviderStateMixin {
  final WisdomService _service = WisdomService();
  WisdomItem? _currentWisdom;
  bool _isShaking = false;
  bool _isSaved = false;

  void _handleTap() async {
    if (_isShaking) return;

    setState(() {
      _isShaking = true;
      _currentWisdom = null;
      _isSaved = false;
    });

    final minDelay = Future.delayed(const Duration(milliseconds: 1200));
    final dataFetch = _service.shakeTheJar();

    final result = await Future.wait([dataFetch, minDelay]);

    if (mounted) {
      setState(() {
        _currentWisdom = result[0] as WisdomItem;
        _isShaking = false;
      });
    }
  }

  // New: Function to close/dismiss the quote
  void _closeQuote() {
    setState(() {
      _currentWisdom = null;
      _isSaved = false;
    });
  }

  void _saveToFavorites() async {
    if (_currentWisdom == null || _isSaved) return;

    final user = AuthService().currentUser;
    if (user == null) return;

    setState(() => _isSaved = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_wisdom')
          .add({
            'text': _currentWisdom!.text,
            'source': _currentWisdom!.source,
            'type': _currentWisdom!.type,
            'savedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Saved to your Wisdom Room"),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSaved = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. THE JAR
        GestureDetector(onTap: _handleTap, child: _buildJarVisual()),

        const SizedBox(height: 12),

        // 2. INSTRUCTION TEXT
        if (_currentWisdom == null && !_isShaking)
          Text(
                "Tap the Jar for Wisdom",
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.6),
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              )
              .animate()
              .fade(duration: 600.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

        if (_isShaking)
          const Text(
            "Mixing wisdom...",
            style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
          ).animate(onPlay: (c) => c.repeat()).fade(),

        // 3. THE PAPER SLIP (With Close Button)
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          child: _currentWisdom == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildPaperSlip(_currentWisdom!),
                ),
        ),
      ],
    );
  }

  Widget _buildJarVisual() {
    Widget jar = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.brown.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.brown.withOpacity(0.3), width: 2),
      ),
      child: const Icon(Icons.cookie, size: 60, color: Colors.brown),
    );

    if (_isShaking) {
      return jar
          .animate(onPlay: (controller) => controller.repeat())
          .shake(hz: 12, rotation: 0.1, curve: Curves.easeInOut);
    }
    return jar;
  }

  Widget _buildPaperSlip(WisdomItem item) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      // NOTE: Removed generic padding here to allow Stack positioning
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6E3),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // A. THE CONTENT
          Padding(
            // Top padding increased to 35 to avoid overlapping with the 'X' button
            padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quote
                Text(
                  '"${item.text}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    fontFamily: 'Times New Roman',
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                const Divider(height: 1, thickness: 0.5, color: Colors.black12),
                const SizedBox(height: 12),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "- ${item.source}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: _saveToFavorites,
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isSaved
                              ? Colors.red.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isSaved
                                ? Colors.red.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSaved ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: _isSaved ? Colors.red : Colors.grey,
                            ),
                            if (_isSaved) ...[
                              const SizedBox(width: 4),
                              const Text(
                                "Saved",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // B. THE CLOSE BUTTON (Top Right)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.black45),
              onPressed: _closeQuote,
              splashRadius: 20,
              tooltip: "Close",
            ),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.2, end: 0);
  }
}
