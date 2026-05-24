// lib/models/pet_model.dart
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String type;
  final double age;
  final double weight;
  final String gender;
  final DateTime createdAt; // FIX: added createdAt for client-side sorting

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.age,
    required this.weight,
    required this.gender,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Pet.fromMap(Map<String, dynamic> data, String documentId) {
    return Pet(
      id: documentId,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      age: (data['age'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      gender: data['gender'] ?? '',
      // FIX: parse createdAt from Firestore Timestamp
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'type': type,
      'age': age,
      'weight': weight,
      'gender': gender,
      'createdAt': DateTime.now(),
    };
  }
}
