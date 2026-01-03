import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/wisdom_service.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:confetti/confetti.dart';

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
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(child: WisdomPopupCard(item: item));
      },
      transitionBuilder: (context, anim1, anim2, child) {
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
        GestureDetector(onTap: _handleTap, child: _buildLivelyJar()),

        // --- CHANGED: Increased height from 16 to 50 for better spacing ---
        const SizedBox(height: 50),

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

  Widget _buildLivelyJar() {
    Widget jarBody = Container(
      width: 140,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.blue.withOpacity(0.05),
            Colors.white.withOpacity(0.1),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildFloatingItem(20, 40, 24, Colors.amberAccent),
          _buildFloatingItem(80, 60, 30, Colors.orangeAccent),
          _buildFloatingItem(40, 90, 20, Colors.purpleAccent),
          _buildFloatingItem(90, 110, 18, Colors.blueAccent),
          Positioned(
            top: 20,
            left: 15,
            child: Container(
              width: 10,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.6), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );

    Widget lid = Container(
      width: 110,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFF8D6E63),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFA1887F), Color(0xFF6D4C41)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    Widget fullJar = Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(padding: const EdgeInsets.only(top: 15.0), child: jarBody),
        lid,
      ],
    );

    if (_isShaking) {
      return fullJar
          .animate(onPlay: (controller) => controller.repeat())
          .shake(hz: 8, rotation: 0.08, curve: Curves.easeInOut);
    }

    return fullJar
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.02,
          duration: 2000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildFloatingItem(double left, double top, double size, Color color) {
    final delay = math.Random().nextInt(1000);
    return Positioned(
      left: left,
      top: top,
      child:
          Icon(
                PhosphorIcons.scroll(PhosphorIconsStyle.fill),
                size: size,
                color: color.withOpacity(0.7),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: -10,
                duration: 2000.ms,
                delay: delay.ms,
                curve: Curves.easeInOut,
              ),
    );
  }
}

// --- POPUP CARD WITH CONFETTI ---
class WisdomPopupCard extends StatefulWidget {
  final WisdomItem item;
  const WisdomPopupCard({super.key, required this.item});

  @override
  State<WisdomPopupCard> createState() => _WisdomPopupCardState();
}

class _WisdomPopupCardState extends State<WisdomPopupCard> {
  late ConfettiController _confettiController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _saveToFavorites() async {
    if (_isSaved) return;

    final user = AuthService().currentUser;
    if (user == null) return;

    setState(() => _isSaved = true);
    _confettiController.play();

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
                const Text("Saved to Wisdom Vault"),
              ],
            ),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSaved = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 1. The Card Itself
        Material(
          color: Colors.transparent,
          child:
              Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.15),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.quotes(),
                          size: 36,
                          color: Colors.amber[800],
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                        const SizedBox(height: 20),
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
                            )
                            .animate()
                            .fade(duration: 800.ms)
                            .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                        const SizedBox(height: 24),
                        Divider(
                              color: Colors.brown.withOpacity(0.1),
                              thickness: 1,
                            )
                            .animate(delay: 200.ms)
                            .fade()
                            .scaleX(begin: 0, end: 1, curve: Curves.easeOut),
                        const SizedBox(height: 16),
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
                                    IconButton(
                                      onPressed: _saveToFavorites,
                                      icon:
                                          Icon(
                                                _isSaved
                                                    ? PhosphorIcons.heart(
                                                        PhosphorIconsStyle.fill,
                                                      )
                                                    : PhosphorIcons.heart(),
                                                color: _isSaved
                                                    ? Colors.redAccent
                                                    : Colors.brown[300],
                                              )
                                              .animate(target: _isSaved ? 1 : 0)
                                              .scale(
                                                begin: const Offset(1, 1),
                                                end: const Offset(1.3, 1.3),
                                                duration: 200.ms,
                                                curve: Curves.easeInOut,
                                              )
                                              .then()
                                              .scale(
                                                begin: const Offset(1.3, 1.3),
                                                end: const Offset(1, 1),
                                              ),
                                      tooltip: "Save to Archive",
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: Icon(
                                        PhosphorIcons.xCircle(),
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                            .animate(delay: 400.ms)
                            .fade()
                            .slideY(begin: 0.2, end: 0),
                        if (_isSaved)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIcons.checkCircle(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  size: 14,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Saved to Wisdom Vault",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ).animate().fade().moveY(begin: 5, end: 0),
                          ),
                      ],
                    ),
                  )
                  .animate()
                  .fade(duration: 400.ms)
                  .scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),
        ),

        // 2. Confetti Widget
        Positioned(
          top: -30,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            createParticlePath: drawStar,
          ),
        ),
      ],
    );
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (math.pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = 360 / numberOfPoints;
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degToRad(degreesPerStep)) {
      path.lineTo(
        halfWidth + externalRadius * math.cos(step),
        halfWidth + externalRadius * math.sin(step),
      );
      path.lineTo(
        halfWidth +
            internalRadius * math.cos(step + degToRad(halfDegreesPerStep)),
        halfWidth +
            internalRadius * math.sin(step + degToRad(halfDegreesPerStep)),
      );
    }
    path.close();
    return path;
  }
}
