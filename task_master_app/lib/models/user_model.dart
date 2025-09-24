import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime? lastTaskCompletionDate;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.createdAt,
    this.lastTaskCompletionDate,
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastTaskCompletionDate: data['lastTaskCompletionDate'] != null
          ? (data['lastTaskCompletionDate'] as Timestamp).toDate()
          : null,
    );
  }

  // Method to convert UserModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'xp': xp,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastTaskCompletionDate': lastTaskCompletionDate != null
          ? Timestamp.fromDate(lastTaskCompletionDate!)
          : null,
    };
  }
}
