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
  final int longestStreak;
  final int totalRelapses;

  // --- NEW FIELD FOR TRIGGER MAP ---
  final Map<String, int> triggerStats;

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
    this.longestStreak = 0,
    this.totalRelapses = 0,
    this.triggerStats = const {}, // Initialize empty
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
      longestStreak: data['longestStreak'] ?? 0,
      totalRelapses: data['totalRelapses'] ?? 0,
      // Safely parse the trigger map
      triggerStats: Map<String, int>.from(data['triggerStats'] ?? {}),
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
      'longestStreak': longestStreak,
      'totalRelapses': totalRelapses,
      'triggerStats': triggerStats, // Save stats to Firestore
    };
  }
}
