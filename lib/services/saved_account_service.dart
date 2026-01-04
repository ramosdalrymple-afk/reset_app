import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String authProvider; // 🟢 ADDED: 'google.com' or 'password'

  SavedUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.authProvider, // 🟢
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'authProvider': authProvider, // 🟢
    };
  }

  factory SavedUser.fromMap(Map<String, dynamic> map) {
    return SavedUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Unknown',
      photoURL: map['photoURL'],
      authProvider: map['authProvider'] ?? 'password', // 🟢 Default to password
    );
  }
}

class SavedAccountService {
  static const String _key = 'saved_accounts';

  // Save the currently logged-in user
  Future<void> saveCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    List<SavedUser> accounts = await getSavedAccounts();

    // Remove existing entry for this UID to update it
    accounts.removeWhere((u) => u.uid == user.uid);

    // 🟢 DETERMINE PROVIDER (Google vs Email)
    String provider = 'password';
    if (user.providerData.isNotEmpty) {
      // providerData[0].providerId usually holds 'google.com' or 'password'
      provider = user.providerData[0].providerId;
    }

    // Add current
    accounts.add(
      SavedUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        photoURL: user.photoURL,
        authProvider: provider, // 🟢 Save the provider
      ),
    );

    // Save back to prefs
    final String encoded = jsonEncode(accounts.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<List<SavedUser>> getSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => SavedUser.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
