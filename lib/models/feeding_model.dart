// lib/models/feeding_model.dart
class FeedingSchedule {
  final String id;
  final String ownerId;
  final String petName;
  final String time;
  final String foodType;
  final DateTime createdAt; // FIX: added for client-side sorting

  FeedingSchedule({
    required this.id,
    required this.ownerId,
    required this.petName,
    required this.time,
    required this.foodType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FeedingSchedule.fromMap(Map<String, dynamic> data, String documentId) {
    return FeedingSchedule(
      id: documentId,
      ownerId: data['ownerId'] ?? '',
      petName: data['petName'] ?? '',
      time: data['time'] ?? '',
      foodType: data['foodType'] ?? '',
      // FIX: parse createdAt
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'petName': petName,
      'time': time,
      'foodType': foodType,
      'createdAt': DateTime.now(),
    };
  }
}
