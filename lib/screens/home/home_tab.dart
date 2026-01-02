import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/theme_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  Timer? _ticker;
  late AnimationController _bgController;

  final List<String> _dailyQuotes = [
    "One day at a time; this is enough. Do not look back.",
    "The secret of getting ahead is getting started.",
    "Recovery is a process, not an event.",
    "Your best days are ahead of you.",
    "Small progress is still progress. Keep going.",
    "Success is the sum of small efforts repeated daily.",
    "Believe you can and you're halfway there.",
  ];

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _bgController.dispose();
    super.dispose();
  }

  String _getQuote() {
    int dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return _dailyQuotes[dayOfYear % _dailyQuotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String habitName = data['habitName'] ?? "Habit";
          final DateTime startDate = DateTime.parse(
            data['startDate'] ?? DateTime.now().toIso8601String(),
          );

          return Scaffold(
            body: Stack(
              children: [
                _buildAnimatedBackground(isDark),
                _buildHomeContent(
                  habitName,
                  startDate,
                  user?.uid,
                  isDark,
                  data,
                ),
              ],
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            color: isDark ? const Color(0xFFCDBEFA) : Colors.blue,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            Positioned(
              top: -100 + (50 * _bgController.value),
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.blue.withOpacity(0.05)
                      : Colors.blue.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 100 - (50 * _bgController.value),
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.purple.withOpacity(0.05)
                      : Colors.purple.withOpacity(0.1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeContent(
    String habitName,
    DateTime startDate,
    String? uid,
    bool isDark,
    Map<String, dynamic> data,
  ) {
    final Duration diff = DateTime.now().difference(startDate);
    final now = DateTime.now();
    final String dateKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String? todayStatus = data['history']?[dateKey];

    bool isAlreadyClean = todayStatus == 'clean';
    bool isStreakTooShort = diff.inSeconds < 30;

    double secPercent = (diff.inSeconds % 60) / 60.0;
    double minPercent = (diff.inMinutes % 60) / 60.0;
    double hourPercent = (diff.inHours % 24) / 24.0;
    double dayPercent = (diff.inDays % 30) / 30.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHeader(habitName, isDark),
            const SizedBox(height: 30),
            _buildTimeBar(
              "${diff.inDays}",
              "days",
              const Color(0xFF2DD4BF),
              dayPercent,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildTimeBar(
              "${diff.inHours % 24}",
              "hours",
              const Color(0xFF3B82F6),
              hourPercent,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildTimeBar(
              "${diff.inMinutes % 60}",
              "minutes",
              const Color(0xFF6366F1),
              minPercent,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildTimeBar(
              "${diff.inSeconds % 60}",
              "seconds",
              const Color(0xFF8B5CF6),
              secPercent,
              isDark,
            ),
            const Spacer(),
            // --- UPDATED QUOTE SECTION ---
            _buildQuoteCard(isDark),
            const SizedBox(height: 32),
            _buildButtonRow(isAlreadyClean, isStreakTooShort, context, uid),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String habitName, bool isDark) {
    return Column(
      children: [
        Text(
          "I've been $habitName free for",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBar(
    String value,
    String label,
    Color color,
    double percentage,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: percentage.clamp(0.02, 1.0)),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, animatedWeight, child) {
                return ClipPath(
                  clipper: TimeBarClipper(),
                  child: Container(
                    height: 60,
                    width: constraints.maxWidth * animatedWeight,
                    decoration: BoxDecoration(
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                );
              },
            ),
            _buildBarText(value, label),
          ],
        );
      },
    );
  }

  Widget _buildBarText(String value, String label) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 20),
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value.padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            const WidgetSpan(child: SizedBox(width: 8)),
            TextSpan(
              text: label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HIGHLIGHTED QUOTE CARD
  Widget _buildQuoteCard(bool isDark) {
    return FadeInUp(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.blue.withOpacity(0.2),
              ),
              boxShadow: [
                if (isDark)
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  color: isDark
                      ? Colors.blueAccent.withOpacity(0.5)
                      : Colors.blueAccent,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  _getQuote(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black87,
                    height: 1.5,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 2,
                  width: 30,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blueAccent.withOpacity(0.3)
                        : Colors.blueAccent.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(
    bool isAlreadyClean,
    bool isStreakTooShort,
    BuildContext context,
    String? uid,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            isAlreadyClean ? "Done for Today" : "I'm Clean Today",
            isAlreadyClean
                ? Colors.grey.withOpacity(0.5)
                : const Color(0xFF2563EB),
            Icons.check_circle_outline,
            isAlreadyClean
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    _confirmClean(context, uid);
                  },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            "I Relapsed",
            isStreakTooShort
                ? Colors.grey.withOpacity(0.5)
                : const Color(0xFF991B1B),
            Icons.history_rounded,
            isStreakTooShort
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    _confirmReset(context, uid);
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: onPressed == null ? 0 : 4,
        shadowColor: color.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _confirmClean(BuildContext context, String? uid) {
    if (uid == null) return;
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    showDialog(
      context: context,
      builder: (confirmContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text("Daily Check-in"),
          content: const Text("Victory logged! Did you stay clean today?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext),
              child: const Text(
                "NOT YET",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(confirmContext);
                final now = DateTime.now().toLocal();
                final String dateKey =
                    "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({'history.$dateKey': 'clean'});
              },
              child: const Text(
                "YES, I'M CLEAN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, String? uid) {
    if (uid == null) return;
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    showDialog(
      context: context,
      builder: (confirmContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text("Be honest with yourself"),
          content: const Text(
            "Resetting is an act of courage. Ready to start again?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(confirmContext);
                final now = DateTime.now().toLocal();
                final String dateKey =
                    "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({
                      'startDate': now.toIso8601String(),
                      'totalRelapses': FieldValue.increment(1),
                      'history.$dateKey': 'relapsed',
                    });
              },
              child: const Text(
                "START FRESH",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FadeInUp extends StatelessWidget {
  final Widget child;
  const FadeInUp({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}

class TimeBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double slantWidth = 35.0;
    path.lineTo(size.width - slantWidth, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
