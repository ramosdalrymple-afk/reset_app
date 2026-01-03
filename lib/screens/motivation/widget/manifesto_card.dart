import 'dart:async'; // Needed for Timer
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/habit_provider.dart';

class ManifestoCard extends StatefulWidget {
  final List<dynamic> items;
  final bool isDark;
  final String? uid;
  final String? habitId;

  const ManifestoCard({
    super.key,
    required this.items,
    required this.isDark,
    this.uid,
    this.habitId,
  });

  @override
  State<ManifestoCard> createState() => _ManifestoCardState();
}

class _ManifestoCardState extends State<ManifestoCard> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- AUTO PLAY LOGIC ---
  void _startAutoPlay() {
    _timer?.cancel(); // Cancel any existing timer
    if (widget.items.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.items.length;
          });
        }
      });
    }
  }

  void _stopAutoPlay() {
    _timer?.cancel();
  }

  // --- CRUD LOGIC ---
  void _addReason() {
    _stopAutoPlay(); // Pause while editing
    _showEditorDialog(initialText: "", isNew: true);
  }

  void _editCurrentReason() {
    if (widget.items.isEmpty) return;
    _stopAutoPlay(); // Pause while editing
    _showEditorDialog(initialText: widget.items[_currentIndex], isNew: false);
  }

  void _deleteCurrentReason() async {
    if (widget.items.isEmpty) return;

    _stopAutoPlay();
    final itemToDelete = widget.items[_currentIndex];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('habits')
        .doc(widget.habitId)
        .update({
          'motivation': FieldValue.arrayRemove([itemToDelete]),
        });

    if (_currentIndex >= widget.items.length - 1) {
      setState(() => _currentIndex = 0);
    }

    if (mounted) {
      Provider.of<HabitProvider>(context, listen: false).fetchHabits();
      // Restart auto play after a short delay so user sees the change
      Future.delayed(const Duration(seconds: 2), _startAutoPlay);
    }
  }

  void _showEditorDialog({required String initialText, required bool isNew}) {
    final controller = TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(isNew ? "New Manifesto" : "Edit Manifesto"),
          content: TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Why are you doing this?",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startAutoPlay(); // Resume if cancelled
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;

                Navigator.pop(context);

                if (isNew) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .collection('habits')
                      .doc(widget.habitId)
                      .update({
                        'motivation': FieldValue.arrayUnion([text]),
                      });
                } else {
                  final oldText = widget.items[_currentIndex];
                  final batch = FirebaseFirestore.instance.batch();
                  final docRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .collection('habits')
                      .doc(widget.habitId);

                  batch.update(docRef, {
                    'motivation': FieldValue.arrayRemove([oldText]),
                  });
                  batch.update(docRef, {
                    'motivation': FieldValue.arrayUnion([text]),
                  });

                  await batch.commit();
                }

                if (mounted) {
                  Provider.of<HabitProvider>(
                    context,
                    listen: false,
                  ).fetchHabits();
                  _startAutoPlay(); // Resume after saving
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // --- NAVIGATION ---
  void _next() {
    _startAutoPlay(); // Reset timer so it doesn't jump immediately after click
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.items.length;
    });
  }

  void _prev() {
    _startAutoPlay(); // Reset timer
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + widget.items.length) % widget.items.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Re-check auto play if items changed (e.g. went from 1 to 2 items)
    if (_timer == null && widget.items.length > 1) {
      _startAutoPlay();
    }

    // Colors
    final textColor = widget.isDark ? Colors.white : const Color(0xFF2D2D2D);
    final watermarkColor = widget.isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);
    final borderColor = widget.isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.6);
    final iconColor = widget.isDark ? Colors.white54 : Colors.black45;

    final hasItems = widget.items.isNotEmpty;
    if (!hasItems) _currentIndex = 0;
    if (hasItems && _currentIndex >= widget.items.length) _currentIndex = 0;

    final String displayText = hasItems
        ? widget.items[_currentIndex]
              .toString() // Ensure string
        : "Tap + to add your manifesto";

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.isDark
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
              // 1. BACKGROUND WATERMARK
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
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  children: [
                    // --- HEADER ROW (Title + Actions) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 60),

                        // Centered Title
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.fire(PhosphorIconsStyle.fill),
                              size: 14,
                              color: widget.isDark
                                  ? Colors.orangeAccent
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "WHY I STARTED",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: widget.isDark
                                    ? Colors.white54
                                    : Colors.black45,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),

                        // Action Buttons
                        Row(
                          children: [
                            _buildMiniBtn(
                              icon: PhosphorIcons.plus(),
                              onTap: _addReason,
                              color: iconColor,
                            ),
                            if (hasItems) ...[
                              const SizedBox(width: 4),
                              _buildMiniBtn(
                                icon: PhosphorIcons.pencilSimple(),
                                onTap: _editCurrentReason,
                                color: iconColor,
                              ),
                              const SizedBox(width: 4),
                              _buildMiniBtn(
                                icon: PhosphorIcons.trash(),
                                onTap: _deleteCurrentReason,
                                color: Colors.red.withOpacity(0.6),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- MAIN CONTENT CAROUSEL ---
                    Row(
                      children: [
                        if (widget.items.length > 1)
                          IconButton(
                            onPressed: _prev,
                            icon: Icon(
                              PhosphorIcons.caretLeft(),
                              color: iconColor,
                            ),
                          )
                        else
                          const SizedBox(width: 48),

                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 600,
                            ), // Slower fade for auto-play feel
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(
                                          0.0,
                                          0.1,
                                        ), // Subtle slide up
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutQuad,
                                        ),
                                      ),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              displayText,
                              key: ValueKey<String>(displayText),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                height: 1.4,
                                fontFamily: 'Georgia',
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),

                        if (widget.items.length > 1)
                          IconButton(
                            onPressed: _next,
                            icon: Icon(
                              PhosphorIcons.caretRight(),
                              color: iconColor,
                            ),
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),

                    // Page Indicator Dots
                    if (widget.items.length > 1) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.items.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 6,
                            width: _currentIndex == index ? 16 : 6,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? (widget.isDark
                                        ? Colors.orangeAccent
                                        : Colors.orange)
                                  : iconColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
