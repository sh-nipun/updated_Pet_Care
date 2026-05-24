// lib/models/appointment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// status flow: pending_admin → confirmed → accepted_vet → done | cancelled
class AppointmentRequest {
  final String id;
  final String ownerId;
  final String ownerName;
  final String vetId;
  final String vetName;
  final String petName;
  final String petType;
  final String requestedDate;   // 'YYYY-MM-DD'
  final String requestedTime;   // 'HH:MM'
  final String notes;
  final String status;
  // filled after done
  final String vetNotes;        // diagnosis / solution
  final double rating;          // 0 if not yet rated
  final String ratingComment;
  final DateTime createdAt;

  AppointmentRequest({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.vetId,
    required this.vetName,
    required this.petName,
    required this.petType,
    required this.requestedDate,
    required this.requestedTime,
    this.notes = '',
    this.status = 'pending_admin',
    this.vetNotes = '',
    this.rating = 0,
    this.ratingComment = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppointmentRequest.fromMap(Map<String, dynamic> d, String id) {
    return AppointmentRequest(
      id: id,
      ownerId: d['ownerId'] ?? '',
      ownerName: d['ownerName'] ?? '',
      vetId: d['vetId'] ?? '',
      vetName: d['vetName'] ?? '',
      petName: d['petName'] ?? '',
      petType: d['petType'] ?? '',
      requestedDate: d['requestedDate'] ?? '',
      requestedTime: d['requestedTime'] ?? '',
      notes: d['notes'] ?? '',
      status: d['status'] ?? 'pending_admin',
      vetNotes: d['vetNotes'] ?? '',
      rating: (d['rating'] ?? 0).toDouble(),
      ratingComment: d['ratingComment'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'ownerName': ownerName,
        'vetId': vetId,
        'vetName': vetName,
        'petName': petName,
        'petType': petType,
        'requestedDate': requestedDate,
        'requestedTime': requestedTime,
        'notes': notes,
        'status': status,
        'vetNotes': vetNotes,
        'rating': rating,
        'ratingComment': ratingComment,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
