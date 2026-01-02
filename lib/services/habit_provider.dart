import 'dart:async';
import 'dart:ui';
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

  // --- FETCH HABITS ---
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
      // 1. Find the local habit to calculate if this was a new longest streak
      final habit = _habits.firstWhere((h) => h.id == habitId);
      final currentStreakDays = DateTime.now()
          .difference(habit.startDate)
          .inDays;

      int newLongestStreak = habit.longestStreak;
      if (currentStreakDays > habit.longestStreak) {
        newLongestStreak = currentStreakDays;
      }

      // 2. Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .update({
            'startDate': Timestamp.now(), // Reset clock to NOW
            'totalRelapses': FieldValue.increment(1),
            'longestStreak': newLongestStreak,
            // Use dot notation to increment the specific trigger count
            'triggerStats.$trigger': FieldValue.increment(1),
            // Mark today as a relapse in history
            'history.${_getTodayKey()}': 'relapse',
          });

      // 3. Refresh data
      await fetchHabits();
    } catch (e) {
      debugPrint("Error resetting habit: $e");
      rethrow;
    }
  }

  // Helper for consistent date keys
  String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
