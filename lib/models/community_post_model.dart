import 'package:cloud_firestore/cloud_firestore.dart';

enum PostColor { blue, pink, green, orange }

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String userInitial;
  // 🟢 THIS must be here
  final String? userProfilePic;

  final String habit;
  final String topic;
  final String content;

  final DateTime timestamp;
  final List<String> likedBy;
  final PostColor color;
  final int commentCount;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userInitial,
    this.userProfilePic,
    required this.habit,
    required this.topic,
    required this.content,
    required this.timestamp,
    required this.likedBy,
    this.color = PostColor.blue,
    this.commentCount = 0,
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
      userProfilePic: data['userProfilePic'],
      habit: data['habit'] ?? 'General',
      topic: data['topic'] ?? 'General',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      color: parsedColor,
      commentCount: data['commentCount'] ?? 0,
    );
  }
}

class Comment {
  final String id;
  final String userName;
  // 🟢 THIS must be here too
  final String? userProfilePic;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userName,
    this.userProfilePic,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userName: data['userName'] ?? 'Anonymous',
      userProfilePic: data['userProfilePic'],
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
