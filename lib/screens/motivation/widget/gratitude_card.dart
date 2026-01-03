import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math';

class GratitudeCard extends StatelessWidget {
  final List<dynamic> items;
  final bool isDark;
  final VoidCallback onAdd;
  final Function(dynamic) onDelete;

  const GratitudeCard({
    super.key,
    required this.items,
    required this.isDark,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Background color for the "Board"
    final boardColor = isDark
        ? const Color(0xFF2D241E)
        : const Color(0xFFF3E5D8); // Corkboard-ish tones
    final headerColor = isDark ? Colors.white : const Color(0xFF4A3B32);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: boardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFD7CCC8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gratitude Board",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: headerColor,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pin your happy moments",
                    style: TextStyle(
                      fontSize: 12,
                      color: headerColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Add Button (Circle)
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: headerColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.add, color: boardColor, size: 24),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- STICKY NOTES GRID ---
          if (items.isEmpty)
            _buildEmptyState(headerColor)
          else
            Wrap(
              spacing: 12, // Gap between notes horizontally
              runSpacing: 12, // Gap between notes vertically
              children: items.asMap().entries.map((entry) {
                final int index = entry.key;
                final dynamic item = entry.value;
                // Alternate colors based on index
                final color = _getStickyColor(index, isDark);

                return _buildStickyNote(item, color, index);
              }).toList(),
            ),
        ],
      ),
    );
  }

  // --- HELPER: STICKY NOTE WIDGET ---
  Widget _buildStickyNote(dynamic item, Color color, int index) {
    // Random slight rotation for natural look (using index to keep it stable)
    final double rotation = (index % 2 == 0) ? -0.02 : 0.02;

    return Transform.rotate(
      angle: rotation,
      child: Dismissible(
        key: ValueKey(item),
        direction: DismissDirection.up, // Swipe UP to remove a note
        onDismissed: (_) => onDelete(item),
        child: Container(
          width: 150, // Fixed width for sticky note look
          height: 150, // Square shape
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
              bottomLeft: Radius.circular(2),
              bottomRight: Radius.circular(20), // Folded corner effect
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pin / Tape visual
              Center(
                child: Container(
                  width: 40,
                  height: 12,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(
                      0xFF333333,
                    ), // Always dark text for contrast on bright notes
                    fontFamily: 'Georgia', // Handwritten feel
                    height: 1.3,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.1), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.pushPin(),
            size: 32,
            color: color.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            "The board is empty.\nAdd a note to start.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: COLOR PALETTE ---
  Color _getStickyColor(int index, bool isDark) {
    // Post-it colors (Yellow, Pink, Cyan, Green)
    final List<Color> lightColors = [
      const Color(0xFFFFF740), // Classic Yellow
      const Color(0xFFFF7EB9), // Pink
      const Color(0xFF7AFCFF), // Cyan
      const Color(0xFFCCFF90), // Green
    ];

    // Slightly dimmed versions for dark mode (so they don't blind the user)
    final List<Color> darkColors = [
      const Color(0xFFE6DE3A),
      const Color(0xFFE671A6),
      const Color(0xFF6DE3E6),
      const Color(0xFFB7E681),
    ];

    final palette = isDark ? darkColors : lightColors;
    return palette[index % palette.length];
  }
}
