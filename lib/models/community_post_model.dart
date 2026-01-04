import 'package:cloud_firestore/cloud_firestore.dart';

enum PostColor { blue, pink, green, orange }

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String userInitial;

  final String habit; // "Smoking"
  final String topic; // "Motivation"
  final String content; // "Content..."

  // PhotoUrl removed as requested

  final DateTime timestamp;
  final List<String> likedBy;
  final PostColor color;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.habit,
    required this.topic,
    required this.content,
    required this.timestamp,
    required this.likedBy,
    this.color = PostColor.blue,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    PostColor parsedColor = PostColor.blue;
    if (data['color'] != null) {
      try {
        parsedColor = PostColor.values.firstWhere(
          (e) => e.name == data['color'],
        );
      } catch (_) {}
    }

    return CommunityPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userInitial: data['userInitial'] ?? 'A',
      habit: data['habit'] ?? 'General',
      topic: data['topic'] ?? 'General',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      color: parsedColor,
    );
  }
}

// 🟢 RESTORED: This class was missing!
class Comment {
  final String id;
  final String userName;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userName,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userName: data['userName'] ?? 'Anonymous',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
