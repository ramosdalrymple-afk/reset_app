import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_auth_project/screens/journal/community_tab.dart';
import 'package:my_auth_project/screens/motivation/widget/stress_popper.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import 'package:my_auth_project/services/theme_provider.dart';
import 'package:my_auth_project/models/habit_model.dart';
import 'package:my_auth_project/services/auth_service.dart';
import 'package:my_auth_project/services/habit_provider.dart';

// 🟢 IMPORT YOUR SCREENS
import 'emergency_screen.dart';

// --- CONFIG ---
const String _geminiKey = "AIzaSyAxMyB-hlB0oWmSRTwk_EQzygo8Hbd0lgQ";
const String _modelName = "gemini-2.5-flash";

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? action;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.action,
  });
}

class AiChatScreen extends StatefulWidget {
  final Habit? habit;

  const AiChatScreen({super.key, this.habit});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickChips = [
    "🔥 I have a strong urge",
    "😞 I feel like giving up",
    "🏆 I need motivation",
    "🆘 I need help now", // Changed to be more relevant to crisis
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HabitProvider>(context, listen: false);
      String intro;

      if (widget.habit != null) {
        intro =
            "Hi. I'm looking at your ${widget.habit!.title} data. How can I help you today?";
      } else if (provider.habits.isNotEmpty) {
        intro =
            "Hi. I see you are tracking ${provider.habits.length} habits. I'm ready to help with any of them.";
      } else {
        intro =
            "Hi. I'm your recovery anchor. You haven't added any habits yet, but I'm here to listen.";
      }

      _addMessage(intro, false);
    });
  }

  void _navigateToFeature(String action) {
    Widget targetScreen;
    switch (action) {
      case 'URGE':
        targetScreen = const EmergencyScreen();
        break;
      case 'STRESS':
        targetScreen = const StressPopperScreen();
        break;
      case 'COMMUNITY':
        targetScreen = const CommunityTab();
        break;
      case 'CRISIS': // 🟢 NEW: Directs to Emergency Screen for help
        targetScreen = const EmergencyScreen();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  // Helper to build the global context string (same as before)
  String _buildGlobalContext() {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final habits = provider.habits;
    final now = DateTime.now();

    if (habits.isEmpty) return "User has NO active habits.";

    StringBuffer buffer = StringBuffer();
    buffer.writeln("OVERVIEW: User is tracking ${habits.length} habits.");
    buffer.writeln("---");

    for (var habit in habits) {
      int streak = now.difference(habit.startDate).inDays;
      bool pledged = false;
      if (habit.lastPledgeDate != null) {
        final p = habit.lastPledgeDate!;
        pledged =
            (p.year == now.year && p.month == now.month && p.day == now.day);
      }
      String focusMarker = (widget.habit?.id == habit.id)
          ? " (CURRENTLY VIEWING)"
          : "";
      buffer.writeln("HABIT: ${habit.title}$focusMarker");
      buffer.writeln("  - Streak: $streak days (Best: ${habit.longestStreak})");
      buffer.writeln("  - Relapses: ${habit.totalRelapses}");
      buffer.writeln("---");
    }
    return buffer.toString();
  }

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;

    _controller.clear();
    _addMessage(text, true);
    setState(() => _isTyping = true);

    try {
      final user = AuthService().currentUser;
      final userName = user?.displayName ?? "Friend";

      final globalStatSheet = _buildGlobalContext();

      // 🟢 CRITICAL UPDATE: ADDED CRISIS PROTOCOL & NUMBERS
      final systemInstruction =
          """
      System: You are 'The Anchor', a recovery coach for $userName.
      
      USER DATA:
      $globalStatSheet

      🚨 CRISIS PROTOCOL (HIGHEST PRIORITY):
      If the user mentions suicide, self-harm, killing themselves, wanting to die, or extreme hopelessness:
      1. IGNORE all habit stats.
      2. Express immediate, non-judgmental concern.
      3. SUGGEST contacting professional help immediately.
      4. IF they ask "who do I call?" or say they don't know, PROVIDE these Philippine numbers:
         - NCMH Crisis Hotline: 1553 (Luzon-wide) or 0917-899-8727
         - Emergency: 911
      5. APPEND the tag <NAV:CRISIS> to your message.

      STANDARD APP TOOLS (Use only for non-crisis habit issues):
      - Urge Assistance: For cravings. Tag: <NAV:URGE>
      - Stress Poppers: For anxiety. Tag: <NAV:STRESS>
      - Community: For loneliness. Tag: <NAV:COMMUNITY>

      Response Guidelines:
      - Be intelligent about their stats (congratulate streaks, warn about triggers).
      - If it is a CRISIS, be direct and helpful.
      - Max 3 sentences (unless listing phone numbers).
      
      User: $text
      """;

      final requestBody = jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": systemInstruction},
            ],
          },
        ],
        // 🟢 SAFETY SETTINGS: MUST BE BLOCK_NONE to allow discussion of "harm" so we can help
        "safetySettings": [
          {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
          {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
          {
            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "threshold": "BLOCK_NONE",
          },
          {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_NONE",
          },
        ],
      });

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$_geminiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          String aiText = data['candidates'][0]['content']['parts'][0]['text'];

          String? detectedAction;

          // 🟢 NEW CRISIS TAG PARSING
          if (aiText.contains('<NAV:CRISIS>')) {
            detectedAction = 'CRISIS';
            aiText = aiText.replaceAll('<NAV:CRISIS>', '').trim();
          } else if (aiText.contains('<NAV:URGE>')) {
            detectedAction = 'URGE';
            aiText = aiText.replaceAll('<NAV:URGE>', '').trim();
          } else if (aiText.contains('<NAV:STRESS>')) {
            detectedAction = 'STRESS';
            aiText = aiText.replaceAll('<NAV:STRESS>', '').trim();
          } else if (aiText.contains('<NAV:COMMUNITY>')) {
            detectedAction = 'COMMUNITY';
            aiText = aiText.replaceAll('<NAV:COMMUNITY>', '').trim();
          }

          if (mounted) {
            setState(() => _isTyping = false);
            _addMessage(aiText, false, action: detectedAction);
          }
        }
      } else {
        debugPrint("🔴 GEMINI ERROR: ${response.statusCode}");
        if (mounted) {
          setState(() => _isTyping = false);
          _addMessage("System: Connection error.", false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        _addMessage("I'm having trouble connecting.", false);
      }
    }
  }

  void _addMessage(String text, bool isUser, {String? action}) {
    setState(() {
      _messages.add(
        ChatMessage(
          id: const Uuid().v4(),
          text: text,
          isUser: isUser,
          timestamp: DateTime.now(),
          action: action,
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- UI PART ---
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length)
                      return _buildTypingIndicator(isDark);
                    return _buildMessageBubble(_messages[index], isDark);
                  },
                ),
              ),
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                _buildQuickChips(isDark),
              _buildInputArea(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isMe = message.isUser;
    Widget? actionWidget;
    if (message.action != null) {
      actionWidget = _buildActionLink(message.action!, isDark);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF3B82F6)
                    : (isDark ? const Color(0xFF1E293B) : Colors.grey[100]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            if (actionWidget != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: actionWidget,
              ),
          ],
        ),
      ),
    ).animate().fade().slideY(
      begin: 0.3,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildActionLink(String action, bool isDark) {
    IconData icon;
    String label;
    Color color;

    switch (action) {
      case 'URGE':
        icon = PhosphorIconsFill.fire;
        label = "Open Urge Assistance";
        color = Colors.orange;
        break;
      case 'STRESS':
        icon = PhosphorIconsFill.balloon;
        label = "Pop Stress Balloons";
        color = Colors.purple;
        break;
      case 'COMMUNITY':
        icon = PhosphorIconsFill.usersThree;
        label = "Go to Community";
        color = Colors.blue;
        break;
      case 'CRISIS': // 🟢 NEW BUTTON STYLE
        icon = PhosphorIconsFill.phoneCall;
        label = "Emergency Support";
        color = Colors.redAccent;
        break;
      default:
        return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => _navigateToFeature(action),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(PhosphorIcons.caretRight(), size: 14, color: color),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms, duration: 300.ms);
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              PhosphorIcons.caretLeft(),
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIconsFill.sparkle,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "The Anchor",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                "Powered by Gemini 2.5",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text("Thinking...", style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildQuickChips(bool isDark) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _quickChips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(_quickChips[index]),
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            onPressed: () => _handleSend(_quickChips[index]),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _handleSend,
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _handleSend(_controller.text),
            child: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(
                PhosphorIconsFill.paperPlaneRight,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
