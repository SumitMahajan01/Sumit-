import 'package:cloud_firestore/cloud_firestore.dart';

class UserAnalyticsModel {
  final String id; // Should be the same as the user's UID
  final Map<String, double> dailyCompletionRates;
  final double consistencyScore;
  final List<Map<String, DateTime>> streakHistory;
  final Map<String, int> productivityByHour;
  final Map<String, int> categoryBreakdown;
  final DateTime lastUpdated;

  UserAnalyticsModel({
    required this.id,
    this.dailyCompletionRates = const {},
    this.consistencyScore = 0.0,
    this.streakHistory = const [],
    this.productivityByHour = const {},
    this.categoryBreakdown = const {},
    required this.lastUpdated,
  });

  factory UserAnalyticsModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserAnalyticsModel(
      id: doc.id,
      dailyCompletionRates: Map<String, double>.from(data['dailyCompletionRates'] ?? {}),
      consistencyScore: (data['consistencyScore'] ?? 0.0).toDouble(),
      streakHistory: (data['streakHistory'] as List<dynamic>?)
          ?.map((history) => {
                'startDate': (history['startDate'] as Timestamp).toDate(),
                'endDate': (history['endDate'] as Timestamp).toDate(),
              })
          .toList() ?? [],
      productivityByHour: Map<String, int>.from(data['productivityByHour'] ?? {}),
      categoryBreakdown: Map<String, int>.from(data['categoryBreakdown'] ?? {}),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyCompletionRates': dailyCompletionRates,
      'consistencyScore': consistencyScore,
      'streakHistory': streakHistory
          .map((history) => {
                'startDate': Timestamp.fromDate(history['startDate']!),
                'endDate': Timestamp.fromDate(history['endDate']!),
              })
          .toList(),
      'productivityByHour': productivityByHour,
      'categoryBreakdown': categoryBreakdown,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
