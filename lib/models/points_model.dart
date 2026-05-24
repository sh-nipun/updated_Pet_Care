// lib/models/points_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPoints {
  final String uid;
  final String fullName;
  final int totalPoints;
  final int activitiesCompleted;
  final DateTime lastUpdated;

  UserPoints({
    required this.uid,
    required this.fullName,
    required this.totalPoints,
    required this.activitiesCompleted,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory UserPoints.fromMap(Map<String, dynamic> d, String uid) => UserPoints(
        uid: uid,
        fullName: d['fullName'] ?? '',
        totalPoints: d['totalPoints'] ?? 0,
        activitiesCompleted: d['activitiesCompleted'] ?? 0,
        lastUpdated: (d['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'totalPoints': totalPoints,
        'activitiesCompleted': activitiesCompleted,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

  /// Points per minute of activity (min 5 pts per activity)
  static int calcPoints(int durationMinutes) =>
      (durationMinutes * 2).clamp(5, 200);

  String get tier {
    if (totalPoints >= 2000) return 'Diamond';
    if (totalPoints >= 1000) return 'Gold';
    if (totalPoints >= 500)  return 'Silver';
    return 'Bronze';
  }

  String get tierEmoji {
    switch (tier) {
      case 'Diamond': return '💎';
      case 'Gold':    return '🥇';
      case 'Silver':  return '🥈';
      default:        return '🥉';
    }
  }
}
