import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_master_app/models/user_model.dart';

class GamificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> awardXp(String userId, int xp) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();

    if (doc.exists) {
      final user = UserModel.fromFirestore(doc);
      final newXp = user.xp + xp;
      final newLevel = _calculateLevel(newXp);

      Map<String, dynamic> updates = {
        'xp': newXp,
      };

      if (newLevel > user.level) {
        updates['level'] = newLevel;
        // Optionally, trigger a notification or celebration for leveling up
      }

      await userRef.update(updates);
    }
  }

  int _calculateLevel(int xp) {
    // A simple formula where every 100 XP is a new level, gets progressively harder
    // For a more gradual curve, you could use a formula like: (0.1 * sqrt(xp)).floor() + 1
    return (xp / 100).floor() + 1;
  }

  Future<void> updateStreak(String userId) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();

    if (doc.exists) {
      final user = UserModel.fromFirestore(doc);
      final now = DateTime.now();

      // Normalize dates to ignore time of day
      final today = DateTime(now.year, now.month, now.day);
      final lastCompletion = user.lastTaskCompletionDate;
      final lastCompletionDay = lastCompletion != null
          ? DateTime(lastCompletion.year, lastCompletion.month, lastCompletion.day)
          : null;

      int newStreak = user.currentStreak;

      if (lastCompletionDay == null) {
        newStreak = 1;
      } else {
        final difference = today.difference(lastCompletionDay).inDays;
        if (difference == 1) {
          // Completed yesterday, continue streak
          newStreak++;
        } else if (difference > 1) {
          // Missed a day, reset streak
          newStreak = 1;
        }
        // if difference is 0, they already completed a task today, streak doesn't change
      }

      Map<String, dynamic> updates = {
        'currentStreak': newStreak,
        'lastTaskCompletionDate': Timestamp.fromDate(now),
      };

      if (newStreak > user.longestStreak) {
        updates['longestStreak'] = newStreak;
      }

      await userRef.update(updates);
    }
  }
}
