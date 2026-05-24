// lib/models/medication_model.dart
class Medication {
  final String id;
  final String ownerId;
  final String petName;
  final String medicationName;
  final String dosage;
  final String scheduledTime;
  bool isTaken;
  final DateTime createdAt; // FIX: added for client-side sorting

  Medication({
    required this.id,
    required this.ownerId,
    required this.petName,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    this.isTaken = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Medication.fromMap(Map<String, dynamic> data, String documentId) {
    return Medication(
      id: documentId,
      ownerId: data['ownerId'] ?? '',
      petName: data['petName'] ?? '',
      medicationName: data['medicationName'] ?? '',
      dosage: data['dosage'] ?? '',
      scheduledTime: data['scheduledTime'] ?? '',
      isTaken: data['isTaken'] ?? false,
      // FIX: parse createdAt
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'petName': petName,
      'medicationName': medicationName,
      'dosage': dosage,
      'scheduledTime': scheduledTime,
      'isTaken': isTaken,
      'createdAt': DateTime.now(),
    };
  }
}
