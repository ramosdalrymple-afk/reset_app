import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:audioplayers/audioplayers.dart'; // <--- NEW IMPORT

class StressPopperScreen extends StatelessWidget {
  const StressPopperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF0F9FF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.arrowLeft(),
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Stress Poppers",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Ambient Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlurBlob(Colors.blue, 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBlurBlob(Colors.purple, 250),
          ),

          // The Grid
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _BubbleWrapGrid(isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.3),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _BubbleWrapGrid extends StatelessWidget {
  final bool isDark;
  const _BubbleWrapGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double itemSize = 70;
        final int crossAxisCount = (constraints.maxWidth / itemSize).floor();

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 50,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            return _PopBubble(isDark: isDark);
          },
        );
      },
    );
  }
}

class _PopBubble extends StatefulWidget {
  final bool isDark;
  const _PopBubble({required this.isDark});

  @override
  State<_PopBubble> createState() => _PopBubbleState();
}

class _PopBubbleState extends State<_PopBubble>
    with SingleTickerProviderStateMixin {
  bool _isPopped = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Audio Player Instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Fast press
    );
    // Connect the controller to a scale animation (1.0 -> 0.95)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  void _pop() async {
    if (_isPopped) return;

    // 1. Haptic Feedback
    HapticFeedback.mediumImpact();

    // 2. Play Sound
    try {
      await _audioPlayer.stop(); // Stop previous if rapid firing
      await _audioPlayer.play(
        AssetSource('sounds/bubble_pop.wav'),
        volume: 0.5,
      );
    } catch (e) {
      debugPrint("Audio Error: $e");
    }

    setState(() {
      _isPopped = true;
    });

    // Play the press animation (down and up)
    _controller.forward().then((_) => _controller.reverse());

    // Auto-regenerate after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isPopped = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark ? Colors.white : Colors.blueGrey;

    // Define shadows explicitly for both states with safe values
    final activeShadows = [
      BoxShadow(
        color: widget.isDark ? Colors.black26 : Colors.blue.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        blurRadius: 4,
        offset: const Offset(-2, -2),
      ),
    ];

    final poppedShadows = [
      BoxShadow(
        color: Colors.transparent,
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.transparent,
        blurRadius: 0,
        offset: const Offset(-2, -2),
      ),
    ];

    return GestureDetector(
      onTap: _pop,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // Safe curve to prevent negative blur crash
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _isPopped
                ? (widget.isDark ? Colors.white10 : Colors.black12)
                : (widget.isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.6)),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isPopped
                  ? Colors.transparent
                  : baseColor.withOpacity(widget.isDark ? 0.2 : 0.5),
              width: 1.5,
            ),
            // Use the safe shadow lists defined above
            boxShadow: _isPopped ? poppedShadows : activeShadows,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isPopped
                ? const SizedBox(width: 70, height: 70) // Empty state
                : Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
