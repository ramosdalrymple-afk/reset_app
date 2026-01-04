import 'package:firebase_auth/firebase_auth.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_auth_project/services/saved_account_service.dart'; // 🟢 ADD IMPORT

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. SIGN UP METHOD (Email/Password)
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sync to Firestore even for email signups
      if (userCredential.user != null) {
        await _syncUserToFirestore(userCredential.user!);
        await SavedAccountService().saveCurrentUser(); // 🟢 SAVE LOCALLY
      }
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // 2. LOGIN METHOD (Email/Password)
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await SavedAccountService().saveCurrentUser(); // 🟢 SAVE LOCALLY
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 3. GOOGLE SIGN-IN METHOD (Desktop Compatible)
  Future<String?> signInWithGoogle() async {
    try {
      final googleArgs = GoogleSignInArgs(
        clientId:
            '485410223126-k7i1o49l08hlq91feo3a7t5tkcfpngsl.apps.googleusercontent.com',
        redirectUri: 'http://localhost',
        scope: 'email profile',
      );

      final result = await DesktopWebviewAuth.signIn(googleArgs);

      if (result != null && result.accessToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: result.accessToken,
          idToken: result.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          await _syncUserToFirestore(userCredential.user!);
          await SavedAccountService().saveCurrentUser(); // 🟢 SAVE LOCALLY
        }

        return "Success";
      }
      return "Sign-in cancelled by user";
    } catch (e) {
      debugPrint("GOOGLE AUTH ERROR: $e");
      return "Authentication failed: ${e.toString()}";
    }
  }

  // Sync basic user data to Firestore
  Future<void> _syncUserToFirestore(User user) async {
    try {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firestore Sync Error: $e");
    }
  }

  // Update Bio and Phone
  Future<void> updateUserProfile({
    required String bio,
    required String phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _db.collection('users').doc(user.uid).set({
          'bio': bio,
          'phoneNumber': phoneNumber,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await SavedAccountService().saveCurrentUser(); // 🟢 UPDATE LOCAL DATA
      } catch (e) {
        debugPrint("Update Profile Error: $e");
        rethrow;
      }
    }
  }

  Stream<DocumentSnapshot> getUserDoc(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> signOut() async => await _auth.signOut();
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
