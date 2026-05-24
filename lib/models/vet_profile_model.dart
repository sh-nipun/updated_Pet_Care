// lib/models/vet_profile_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VetProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String clinicName;
  final String address;
  final String degree;          // e.g. BVSc & AH, MVSc
  final String specialization;  // e.g. Small Animals, Surgery
  final List<String> workingDays; // ['Monday','Tuesday',...]
  final String workStartTime;   // '09:00'
  final String workEndTime;     // '18:00'
  final double rating;
  final int totalRatings;
  final bool isApproved;        // admin must approve
  final DateTime createdAt;

  VetProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.clinicName = '',
    this.address = '',
    this.degree = '',
    this.specialization = '',
    this.workingDays = const [],
    this.workStartTime = '09:00',
    this.workEndTime = '18:00',
    this.rating = 0.0,
    this.totalRatings = 0,
    this.isApproved = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory VetProfile.fromMap(Map<String, dynamic> d, String uid) {
    return VetProfile(
      uid: uid,
      fullName: d['fullName'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      clinicName: d['clinicName'] ?? '',
      address: d['address'] ?? '',
      degree: d['degree'] ?? '',
      specialization: d['specialization'] ?? '',
      workingDays: List<String>.from(d['workingDays'] ?? []),
      workStartTime: d['workStartTime'] ?? '09:00',
      workEndTime: d['workEndTime'] ?? '18:00',
      rating: (d['rating'] ?? 0).toDouble(),
      totalRatings: d['totalRatings'] ?? 0,
      isApproved: d['isApproved'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'clinicName': clinicName,
        'address': address,
        'degree': degree,
        'specialization': specialization,
        'workingDays': workingDays,
        'workStartTime': workStartTime,
        'workEndTime': workEndTime,
        'rating': rating,
        'totalRatings': totalRatings,
        'isApproved': isApproved,
        'createdAt': FieldValue.serverTimestamp(),
      };

  String get availabilityText =>
      '${workingDays.join(', ')} · $workStartTime – $workEndTime';
}
