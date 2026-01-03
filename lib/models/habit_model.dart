import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final String motivation;
  final DateTime startDate;
  final String category;
  final String icon;

  // --- STATS & DATA ---
  final Map<String, dynamic> history;
  final List<String> gains;
  final List<String> losses;
  // --- NEW: GRATITUDE LIST ---
  final List<String> gratitude;

  final int longestStreak;
  final int totalRelapses;

  // --- TRIGGER MAP ---
  final Map<String, int> triggerStats;

  // --- NEW: PLEDGE DATE ---
  final DateTime? lastPledgeDate;

  Habit({
    required this.id,
    required this.title,
    required this.startDate,
    this.motivation = "To become a better version of myself.",
    this.category = "General",
    this.icon = "⭐",
    this.history = const {},
    this.gains = const [],
    this.losses = const [],
    // Initialize gratitude with empty list
    this.gratitude = const [],
    this.longestStreak = 0,
    this.totalRelapses = 0,
    this.triggerStats = const {},
    this.lastPledgeDate,
  });

  factory Habit.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    DateTime parsedDate;
    if (data['startDate'] is Timestamp) {
      parsedDate = (data['startDate'] as Timestamp).toDate();
    } else if (data['startDate'] is String) {
      parsedDate = DateTime.parse(data['startDate']);
    } else {
      parsedDate = DateTime.now();
    }

    return Habit(
      id: doc.id,
      title: data['title'] ?? '',
      motivation: data['motivation'] ?? "To become a better version of myself.",
      startDate: parsedDate,
      category: data['category'] ?? 'General',
      icon: data['icon'] ?? '⭐',
      history: Map<String, dynamic>.from(data['history'] ?? {}),
      gains: List<String>.from(data['gains'] ?? []),
      losses: List<String>.from(data['losses'] ?? []),
      // Parse gratitude list safely
      gratitude: List<String>.from(data['gratitude'] ?? []),
      longestStreak: data['longestStreak'] ?? 0,
      totalRelapses: data['totalRelapses'] ?? 0,
      triggerStats: Map<String, int>.from(data['triggerStats'] ?? {}),
      lastPledgeDate: data['lastPledgeDate'] != null
          ? (data['lastPledgeDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'motivation': motivation,
      'startDate': Timestamp.fromDate(startDate),
      'category': category,
      'icon': icon,
      'history': history,
      'gains': gains,
      'losses': losses,
      // Save gratitude to Firebase
      'gratitude': gratitude,
      'longestStreak': longestStreak,
      'totalRelapses': totalRelapses,
      'triggerStats': triggerStats,
      'lastPledgeDate': lastPledgeDate != null
          ? Timestamp.fromDate(lastPledgeDate!)
          : null,
    };
  }
}
