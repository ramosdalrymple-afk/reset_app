import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_model.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  Habit? _selectedHabit;
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  Habit? get selectedHabit => _selectedHabit;
  bool get isLoading => _isLoading;

  // --- EXISTING GETTERS & METHODS ---

  Map<String, dynamic> get combinedHistory {
    final Map<String, dynamic> combined = {};
    for (final habit in _habits) {
      habit.history.forEach((dateKey, status) {
        if (combined.containsKey(dateKey)) {
          if (status == 'relapse') {
            combined[dateKey] = 'relapse';
          }
        } else {
          combined[dateKey] = status;
        }
      });
    }
    return combined;
  }

  bool get isPledgedToday {
    if (_selectedHabit?.lastPledgeDate == null) return false;
    final now = DateTime.now();
    final pledge = _selectedHabit!.lastPledgeDate!;
    return now.year == pledge.year &&
        now.month == pledge.month &&
        now.day == pledge.day;
  }

  // --- NEW: TRIGGER TRACKING LOGIC ---

  // 1. Log a new trigger
  Future<void> logTrigger({
    required String habitId,
    required String triggerName,
    required int intensity, // 1-10
    required String note,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .doc(habitId)
          .collection('trigger_logs') // New Sub-collection
          .add({
            'triggerName': triggerName,
            'intensity': intensity,
            'note': note,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint("Error logging trigger: $e");
      rethrow;
    }
  }

  // 2. Get stream of logs (Real-time updates)
  Stream<QuerySnapshot> getTriggerLogsStream(String habitId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habitId)
        .collection('trigger_logs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 3. DELETE TRIGGER LOG (NEW)
  Future<void> deleteTriggerLog(String habitId, String logId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .doc(habitId)
          .collection('trigger_logs')
          .doc(logId)
          .delete();
    } catch (e) {
      debugPrint("Error deleting trigger log: $e");
      rethrow;
    }
  }

  // --- MOTIVATION MANAGEMENT ---

  // 1. ADD REASON
  Future<void> addMotivation(String habitId, String reason) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .doc(habitId)
          .update({
            'motivation': FieldValue.arrayUnion([reason]),
          });

      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index].motivation.add(reason);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error adding motivation: $e");
    }
  }

  // 2. EDIT REASON
  Future<void> editMotivation(
    String habitId,
    String oldReason,
    String newReason,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .doc(habitId);

      final batch = FirebaseFirestore.instance.batch();
      batch.update(docRef, {
        'motivation': FieldValue.arrayRemove([oldReason]),
      });
      batch.update(docRef, {
        'motivation': FieldValue.arrayUnion([newReason]),
      });
      await batch.commit();

      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        final reasonIndex = _habits[index].motivation.indexOf(oldReason);
        if (reasonIndex != -1) {
          _habits[index].motivation[reasonIndex] = newReason;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error editing motivation: $e");
    }
  }

  // 3. DELETE REASON
  Future<void> deleteMotivation(String habitId, String reason) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .doc(habitId)
          .update({
            'motivation': FieldValue.arrayRemove([reason]),
          });

      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index].motivation.remove(reason);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error deleting motivation: $e");
    }
  }

  // --- HABIT ACTIONS ---

  Future<void> takeDailyPledge(String habitId, String mood, String note) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final now = DateTime.now();
      final habitRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('habits')
          .doc(habitId);
      await habitRef.update({'lastPledgeDate': Timestamp.fromDate(now)});
      await habitRef.collection('pledgeHistory').add({
        'date': Timestamp.fromDate(now),
        'mood': mood,
        'note': note,
      });
      await fetchHabits();
    } catch (e) {
      debugPrint("Pledge Error: $e");
    }
  }

  Stream<QuerySnapshot> getPledgeHistoryStream(String habitId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habitId)
        .collection('pledgeHistory')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> fetchHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _isLoading = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .orderBy('startDate', descending: true)
          .get();

      _habits = snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();

      if (_habits.isNotEmpty) {
        if (_selectedHabit == null ||
            !_habits.any((h) => h.id == _selectedHabit!.id)) {
          _selectedHabit = _habits.first;
        } else {
          _selectedHabit = _habits.firstWhere(
            (h) => h.id == _selectedHabit!.id,
          );
        }
      } else {
        _selectedHabit = null;
      }
    } catch (e) {
      debugPrint("Error fetching habits: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectHabit(Habit habit) {
    _selectedHabit = habit;
    notifyListeners();
  }

  Future<void> addHabit(String title, DateTime date, String motivation) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final newDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc();
      final newHabit = Habit(
        id: newDoc.id,
        title: title,
        startDate: date,
        motivation: [motivation],
      );
      await newDoc.set(newHabit.toMap());
      _habits.insert(0, newHabit);
      _selectedHabit = newHabit;
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding habit: $e");
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .delete();
      _habits.removeWhere((h) => h.id == habitId);
      if (_selectedHabit?.id == habitId) {
        if (_habits.isNotEmpty) {
          _selectedHabit = _habits.first;
        } else {
          _selectedHabit = null;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting habit: $e");
      rethrow;
    }
  }

  Future<void> markDayClean(String habitId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final now = DateTime.now();
    final String dateKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .update({'history.$dateKey': 'clean'});
      await fetchHabits();
    } catch (e) {
      debugPrint("Error marking clean: $e");
      rethrow;
    }
  }

  Future<void> resetHabit(String habitId, {required String trigger}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final habit = _habits.firstWhere((h) => h.id == habitId);
      final currentStreakDays = DateTime.now()
          .difference(habit.startDate)
          .inDays;
      int newLongestStreak = habit.longestStreak;
      if (currentStreakDays > habit.longestStreak) {
        newLongestStreak = currentStreakDays;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .update({
            'startDate': Timestamp.now(),
            'totalRelapses': FieldValue.increment(1),
            'longestStreak': newLongestStreak,
            'triggerStats.$trigger': FieldValue.increment(1),
            'history.${_getTodayKey()}': 'relapse',
          });
      await fetchHabits();
    } catch (e) {
      debugPrint("Error resetting habit: $e");
      rethrow;
    }
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
