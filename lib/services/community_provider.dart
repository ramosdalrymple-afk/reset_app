import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_post_model.dart';

class CommunityProvider with ChangeNotifier {
  Stream<List<CommunityPost>> get postsStream {
    return FirebaseFirestore.instance
        .collection('community_posts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPost.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    return FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addPost({
    required String habit,
    required String topic,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String name = user.displayName ?? "Anonymous";
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : "A";
    final randomColor =
        PostColor.values[Random().nextInt(PostColor.values.length)];

    try {
      await FirebaseFirestore.instance.collection('community_posts').add({
        'userId': user.uid,
        'userName': name,
        'userInitial': initial,
        'habit': habit,
        'topic': topic,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'color': randomColor.name,
      });
    } catch (e) {
      debugPrint("Error posting story: $e");
      rethrow;
    }
  }

  // 🟢 NEW: Update Post
  Future<void> updatePost({
    required String postId,
    required String habit,
    required String topic,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .update({
          'habit': habit,
          'topic': topic,
          'content': content,
          // We don't update timestamp so it stays in original order
        });
  }

  // 🟢 NEW: Delete Post
  Future<void> deletePost(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .delete();
  }

  Future<void> toggleLike(String postId, List<String> currentLikes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId);
    if (currentLikes.contains(user.uid)) {
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  Future<void> addComment(String postId, String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final String name = user.displayName ?? "Anonymous";
    await FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .add({
          'userId': user.uid,
          'userName': name,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}
