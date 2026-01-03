import 'dart:ui';
import 'package:flutter/material.dart';

class QuoteCard extends StatefulWidget {
  final bool isDark;
  final String quote;
  final String author;
  final VoidCallback? onSave; // NEW: Callback when heart is clicked

  const QuoteCard({
    super.key,
    required this.isDark,
    required this.quote,
    this.author = "",
    this.onSave,
  });

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  bool _isSaved = false; // Local state to turn the heart red immediately

  @override
  void didUpdateWidget(covariant QuoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the quote text changes (new day/refresh), reset the heart
    if (oldWidget.quote != widget.quote) {
      setState(() {
        _isSaved = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            // Removed internal padding here to let Stack control layout
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white10
                    : Colors.blue.withOpacity(0.2),
              ),
              boxShadow: [
                if (widget.isDark)
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Stack(
              children: [
                // 1. THE CONTENT
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        color: widget.isDark
                            ? Colors.blueAccent.withOpacity(0.5)
                            : Colors.blueAccent,
                        size: 32,
                      ),
                      const SizedBox(height: 12),

                      // Quote Text
                      Text(
                        widget.quote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black87,
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                      ),

                      // Author Text
                      if (widget.author.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          "- ${widget.author}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark
                                ? Colors.white54
                                : Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Decorative Line
                      Container(
                        height: 2,
                        width: 30,
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.blueAccent.withOpacity(0.3)
                              : Colors.blueAccent.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. THE HEART BUTTON (Top Right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      _isSaved ? Icons.favorite : Icons.favorite_border,
                      color: _isSaved
                          ? Colors.redAccent
                          : (widget.isDark ? Colors.white30 : Colors.black26),
                      size: 20,
                    ),
                    onPressed: () {
                      if (!_isSaved) {
                        setState(() => _isSaved = true);
                        if (widget.onSave != null) widget.onSave!();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
