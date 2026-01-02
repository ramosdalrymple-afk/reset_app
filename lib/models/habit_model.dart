import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final DateTime startDate;
  final String category; // e.g., "Sobriety", "Health", "Study"
  final String icon;

  Habit({
    required this.id,
    required this.title,
    required this.startDate,
    this.category = "General",
    this.icon = "⭐",
  });

  // Convert Firestore Document to Habit Object
  factory Habit.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id,
      title: data['title'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      category: data['category'] ?? 'General',
      icon: data['icon'] ?? '⭐',
    );
  }

  // Convert Habit Object to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'category': category,
      'icon': icon,
    };
  }
}
