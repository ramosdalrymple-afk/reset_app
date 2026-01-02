import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final String motivation; // <--- ADDED THIS FIELD
  final DateTime startDate;
  final String category;
  final String icon;

  // --- STATS & DATA ---
  final Map<String, dynamic> history; // For the Calendar
  final List<String> gains; // For Motivation Tab
  final List<String> losses; // For Motivation Tab
  final int longestStreak; // For Home Tab
  final int totalRelapses; // For Home Tab

  Habit({
    required this.id,
    required this.title,
    required this.startDate,
    this.motivation =
        "To become a better version of myself.", // <--- Default value
    this.category = "General",
    this.icon = "⭐",
    // Initialize with defaults so the app doesn't crash if data is missing
    this.history = const {},
    this.gains = const [],
    this.losses = const [],
    this.longestStreak = 0,
    this.totalRelapses = 0,
  });

  // Convert Firestore Document to Habit Object
  factory Habit.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    // Logic to safely handle Date (prevents crashes if it's saved as String vs Timestamp)
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
      motivation:
          data['motivation'] ??
          "To become a better version of myself.", // <--- Read from DB
      startDate: parsedDate,
      category: data['category'] ?? 'General',
      icon: data['icon'] ?? '⭐',

      // Load the stats data
      history: Map<String, dynamic>.from(data['history'] ?? {}),
      gains: List<String>.from(data['gains'] ?? []),
      losses: List<String>.from(data['losses'] ?? []),
      longestStreak: data['longestStreak'] ?? 0,
      totalRelapses: data['totalRelapses'] ?? 0,
    );
  }

  // Convert Habit Object to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'motivation': motivation, // <--- Save to DB
      'startDate': Timestamp.fromDate(startDate),
      'category': category,
      'icon': icon,
      'history': history,
      'gains': gains,
      'losses': losses,
      'longestStreak': longestStreak,
      'totalRelapses': totalRelapses,
    };
  }
}
