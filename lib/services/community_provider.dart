import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_post_model.dart';

class CommunityProvider with ChangeNotifier {
  // Track the current filter state
  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  // 🟢 UPDATED: Return ALL posts (Raw Data)
  // We will do the filtering in the UI. This ensures we can calculate
  // the list of available filters correctly without them disappearing.
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

  // Set the filter and notify UI to rebuild
  void setFilter(String habit) {
    _selectedFilter = habit;
    notifyListeners();
  }

  // ... (Keep the rest of your methods: getCommentsStream, addPost, updatePost, etc. exactly as they were)

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
    final String? photoUrl = user.photoURL;

    final randomColor =
        PostColor.values[Random().nextInt(PostColor.values.length)];

    try {
      await FirebaseFirestore.instance.collection('community_posts').add({
        'userId': user.uid,
        'userName': name,
        'userInitial': initial,
        'userProfilePic': photoUrl,
        'habit': habit,
        'topic': topic,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'color': randomColor.name,
        'commentCount': 0,
      });
    } catch (e) {
      debugPrint("Error posting story: $e");
      rethrow;
    }
  }

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
        .update({'habit': habit, 'topic': topic, 'content': content});
  }

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
    final String? photoUrl = user.photoURL;

    final postRef = FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId);
    final batch = FirebaseFirestore.instance.batch();

    final commentRef = postRef.collection('comments').doc();
    batch.set(commentRef, {
      'userId': user.uid,
      'userName': name,
      'userProfilePic': photoUrl,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(postRef, {'commentCount': FieldValue.increment(1)});

    await batch.commit();
  }
}
