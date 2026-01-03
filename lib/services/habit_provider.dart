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

  // --- NEW: AGGREGATE HISTORY (ALL HABITS) ---
  // This is used by the "All Habits" toggle on the Progress Page.
  Map<String, dynamic> get combinedHistory {
    final Map<String, dynamic> combined = {};

    for (final habit in _habits) {
      habit.history.forEach((dateKey, status) {
        // If we already have a status for this date...
        if (combined.containsKey(dateKey)) {
          // If the NEW status is 'relapse', it overrides 'clean'.
          // (Because 1 relapse means the day wasn't perfect).
          if (status == 'relapse') {
            combined[dateKey] = 'relapse';
          }
        } else {
          // No entry for this date yet, just take the status.
          combined[dateKey] = status;
        }
      });
    }
    return combined;
  }

  // --- PLEDGE LOGIC ---
  bool get isPledgedToday {
    if (_selectedHabit?.lastPledgeDate == null) return false;

    final now = DateTime.now();
    final pledge = _selectedHabit!.lastPledgeDate!;

    return now.year == pledge.year &&
        now.month == pledge.month &&
        now.day == pledge.day;
  }

  // UPDATED: Now accepts mood and note
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

      // 1. Update Firestore Main Doc (for UI badge)
      await habitRef.update({'lastPledgeDate': Timestamp.fromDate(now)});

      // 2. Add to History Sub-collection (for Graphs/Journal)
      await habitRef.collection('pledgeHistory').add({
        'date': Timestamp.fromDate(now),
        'mood': mood,
        'note': note,
      });

      // 3. Refresh Data
      await fetchHabits();
    } catch (e) {
      debugPrint("Pledge Error: $e");
    }
  }

  // --- FETCH PLEDGE HISTORY STREAM ---
  Stream<QuerySnapshot> getPledgeHistoryStream(String habitId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habitId)
        .collection('pledgeHistory')
        .orderBy('date', descending: true) // Newest entries first
        .snapshots();
  }
  // -------------------------

  // --- FETCH HABITS ---
  Future<void> fetchHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    // notifyListeners(); // Optional: Uncomment if you want loading spinners immediately

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .orderBy('startDate', descending: true)
          .get();

      _habits = snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();

      if (_habits.isNotEmpty) {
        // logic to keep the currently selected habit selected if it still exists
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

  // --- SELECT HABIT ---
  void selectHabit(Habit habit) {
    _selectedHabit = habit;
    notifyListeners();
  }

  // --- ADD HABIT ---
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
        motivation: motivation,
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

  // --- DELETE HABIT ---
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

  // --- MARK DAY AS CLEAN ---
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

  // --- RESET HABIT (RELAPSE) WITH TRIGGER MAP ---
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
