import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';
import 'emergency_screen.dart';

class MotivationTab extends StatefulWidget {
  const MotivationTab({super.key});

  @override
  State<MotivationTab> createState() => _MotivationTabState();
}

class _MotivationTabState extends State<MotivationTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  // Animated Starfield Background
  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            ...List.generate(15, (index) {
              double startX =
                  (index * 40.0) % MediaQuery.of(context).size.width;
              double startY =
                  (index * 70.0) % MediaQuery.of(context).size.height;
              double currentX =
                  (startX + (_bgController.value * 200)) %
                  MediaQuery.of(context).size.width;
              double currentY =
                  (startY - (_bgController.value * 300)) %
                  MediaQuery.of(context).size.height;

              return Positioned(
                left: currentX,
                top: currentY,
                child: Container(
                  width: (index % 3 + 2).toDouble(),
                  height: (index % 3 + 2).toDouble(),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.blue.withOpacity(0.2),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(isDark),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

              // Safe Data Logic: Prevents crashes if Firestore has old String data
              final String rootWhy =
                  data['motivation'] ?? "To build a better version of myself.";
              final rawGains = data['gains'];
              final List<dynamic> gains = (rawGains is List)
                  ? rawGains
                  : ["Energy", "Mental clarity", "Self-respect"];
              final rawLosses = data['losses'];
              final List<dynamic> losses = (rawLosses is List)
                  ? rawLosses
                  : ["Time", "Peace of mind"];

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "REMEMBER YOUR WHY",
                        style: TextStyle(
                          color: isDark ? const Color(0xFFCDBEFA) : Colors.blue,
                          letterSpacing: 1.5,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Daily Motivation",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildEmergencyButton(context),
                      const SizedBox(height: 32),

                      _buildSectionHeader(
                        "The Root Purpose",
                        Icons.anchor_rounded,
                      ),
                      _buildMotivationCard(rootWhy, isDark),

                      const SizedBox(height: 32),
                      _buildListSection(
                        context,
                        user?.uid,
                        "What I gain",
                        "gains",
                        gains,
                        const Color(0xFF2DD4BF),
                        isDark,
                      ),

                      const SizedBox(height: 32),
                      _buildListSection(
                        context,
                        user?.uid,
                        "What I lose",
                        "losses",
                        losses,
                        Colors.redAccent,
                        isDark,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    BuildContext context,
    String? uid,
    String title,
    String dbKey,
    List<dynamic> items,
    Color accentColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(title, Icons.list_rounded),
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: accentColor,
                size: 24,
              ),
              onPressed: () => _showAddSheet(context, uid, title, dbKey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () => _deleteItem(uid, dbKey, item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- INTEGRATED: INSTANT-CLOSING BOTTOM SHEET ---
  void _showAddSheet(
    BuildContext context,
    String? uid,
    String title,
    String key,
  ) {
    final controller = TextEditingController();
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NEW ${title.toUpperCase()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 14,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter reason...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? Colors.black26 : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      // 1. POP INSTANTLY: This removes the sheet immediately
                      Navigator.of(sheetContext).pop();

                      // 2. BACKGROUND SYNC: Update Firebase without making the UI wait
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({
                            key: FieldValue.arrayUnion([text]),
                          })
                          .catchError((e) => debugPrint("Sync error: $e"));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "ADD TO LIST",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteItem(String? uid, String key, dynamic item) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      key: FieldValue.arrayRemove([item]),
    });
  }

  Widget _buildSectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
      ],
    ),
  );

  Widget _buildMotivationCard(String text, bool isDark) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Text(
          "\"$text\"",
          style: TextStyle(
            fontSize: 17,
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white : Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    ),
  );

  Widget _buildEmergencyButton(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const EmergencyScreen())),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB91C1C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      icon: const Icon(Icons.bolt_rounded),
      label: const Text(
        "PANIC BUTTON",
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    ),
  );
}
