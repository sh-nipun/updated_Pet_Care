// lib/models/activity_model.dart
class Activity {
  final String id;
  final String ownerId;
  final String petName;
  final String activityName;
  final int durationMinutes;
  final DateTime date;
  final DateTime createdAt; // FIX: added for completeness

  Activity({
    required this.id,
    required this.ownerId,
    required this.petName,
    required this.activityName,
    required this.durationMinutes,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Activity.fromMap(Map<String, dynamic> data, String documentId) {
    return Activity(
      id: documentId,
      ownerId: data['ownerId'] ?? '',
      petName: data['petName'] ?? '',
      activityName: data['activityName'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      date: (data['date'] as dynamic)?.toDate() ?? DateTime.now(),
      // FIX: parse createdAt
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'petName': petName,
      'activityName': activityName,
      'durationMinutes': durationMinutes,
      'date': date,
      'createdAt': DateTime.now(),
    };
  }
}
