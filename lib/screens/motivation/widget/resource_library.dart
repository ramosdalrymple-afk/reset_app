import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ResourceLibrary extends StatelessWidget {
  final bool isDark;
  const ResourceLibrary({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text(
                  "Resource Library",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
          ),
          _buildExpansionGroup(
            context,
            "Helplines",
            PhosphorIcons.phone(),
            [
              _buildResourceItem(
                "SAMHSA National Helpline",
                "Confidential free help from public health agencies. 24/7.",
                isDark,
              ),
              _buildResourceItem(
                "National Suicide Prevention",
                "Provides 24/7, free and confidential support.",
                isDark,
              ),
            ],
            isDark,
            true,
          ),
          _buildExpansionGroup(
            context,
            "Online Communities",
            PhosphorIcons.chatCircle(),
            [
              _buildResourceItem(
                "Smart Recovery Forum",
                "Science-based, self-empowered recovery group.",
                isDark,
              ),
              _buildResourceItem(
                "Reddit r/stopdrinking",
                "A place to motivate each other.",
                isDark,
              ),
            ],
            isDark,
            false,
          ),
          _buildExpansionGroup(
            context,
            "Articles & Reading",
            PhosphorIcons.bookOpen(),
            [
              _buildResourceItem(
                "Understanding Triggers",
                "Learn how to identify and manage your personal triggers.",
                isDark,
              ),
              _buildResourceItem(
                "The Science of Habits",
                "How dopamine affects the brain and how to rewire it.",
                isDark,
              ),
            ],
            isDark,
            false,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildExpansionGroup(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
    bool isDark,
    bool initExpanded,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initExpanded,
        leading: Icon(
          icon,
          color: isDark ? Colors.blueAccent : const Color(0xFF64748B),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF334155),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: children,
      ),
    );
  }

  Widget _buildResourceItem(String title, String subtitle, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            PhosphorIcons.arrowSquareOut(),
            size: 18,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ],
      ),
    );
  }
}
