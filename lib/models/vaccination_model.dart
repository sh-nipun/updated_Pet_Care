// lib/models/vaccination_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccination {
  final String id;
  final String ownerId;
  final String petName;
  final String vaccineName;
  final DateTime dateTaken;
  final DateTime nextDue;
  final DateTime createdAt;

  Vaccination({
    required this.id,
    required this.ownerId,
    required this.petName,
    required this.vaccineName,
    required this.dateTaken,
    required this.nextDue,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue => nextDue.isBefore(DateTime.now());

  factory Vaccination.fromMap(Map<String, dynamic> d, String id) {
    return Vaccination(
      id: id,
      ownerId: d['ownerId'] ?? '',
      petName: d['petName'] ?? '',
      vaccineName: d['vaccineName'] ?? '',
      dateTaken: (d['dateTaken'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nextDue: (d['nextDue'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'petName': petName,
        'vaccineName': vaccineName,
        'dateTaken': dateTaken,
        'nextDue': nextDue,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

// --- Auto Vaccine Recommendation Engine ---
class VaccineRecommendation {
  final String vaccineName;
  final String description;
  final String recommendedAt; // e.g. '8 weeks', '1 year'
  final String frequency;     // e.g. 'Annual', 'Every 3 years'
  final bool isCore;

  const VaccineRecommendation({
    required this.vaccineName,
    required this.description,
    required this.recommendedAt,
    required this.frequency,
    required this.isCore,
  });
}

class VaccineScheduleEngine {
  // ── DOG schedule (WSAVA / AAHA guidelines) ──────────────────────────
  static const List<Map<String, dynamic>> _dogSchedule = [
    {'name': 'DHPPi (Distemper, Hepatitis, Parvo, Parainfluenza)', 'weeks': 8, 'isCore': true, 'freq': 'Booster at 12w, 16w then every 3 years', 'desc': 'Core puppy vaccine – protects against 4 major diseases'},
    {'name': 'DHPPi Booster #2', 'weeks': 12, 'isCore': true, 'freq': 'Part of primary series', 'desc': 'Second dose of core puppy series'},
    {'name': 'DHPPi Booster #3 + Rabies', 'weeks': 16, 'isCore': true, 'freq': 'Rabies annually or every 3y by law', 'desc': 'Final puppy DHPPi + first Rabies vaccine'},
    {'name': 'Rabies Annual Booster', 'months': 13, 'isCore': true, 'freq': 'Annual or every 3 years', 'desc': 'Legally required in most regions'},
    {'name': 'Leptospirosis', 'weeks': 12, 'isCore': false, 'freq': 'Annual', 'desc': 'Recommended in high-exposure areas (water, wildlife contact)'},
    {'name': 'Bordetella (Kennel Cough)', 'months': 4, 'isCore': false, 'freq': 'Annual or every 6 months', 'desc': 'Recommended before boarding, grooming, dog parks'},
    {'name': 'Canine Influenza (H3N2/H3N8)', 'months': 4, 'isCore': false, 'freq': 'Annual', 'desc': 'Recommended for social dogs'},
    {'name': 'Annual DHPPi Booster (Adult)', 'months': 15, 'isCore': true, 'freq': 'Every 1–3 years', 'desc': 'Adult maintenance booster'},
  ];

  // ── CAT schedule (WSAVA / AAFP guidelines) ───────────────────────────
  static const List<Map<String, dynamic>> _catSchedule = [
    {'name': 'FVRCP (Feline Distemper, Rhinotracheitis, Calicivirus)', 'weeks': 8, 'isCore': true, 'freq': 'Booster at 12w, 16w then every 3 years', 'desc': 'Core kitten vaccine – "feline distemper" combo'},
    {'name': 'FVRCP Booster #2', 'weeks': 12, 'isCore': true, 'freq': 'Part of primary series', 'desc': 'Second dose of kitten series'},
    {'name': 'FVRCP Booster #3 + Rabies', 'weeks': 16, 'isCore': true, 'freq': 'Rabies annually or every 3 years', 'desc': 'Final kitten FVRCP + first Rabies'},
    {'name': 'Rabies Annual Booster', 'months': 13, 'isCore': true, 'freq': 'Annual or every 3 years', 'desc': 'Legally required in most regions'},
    {'name': 'FeLV (Feline Leukemia Virus)', 'weeks': 9, 'isCore': false, 'freq': 'Annual for outdoor cats', 'desc': 'Recommended for outdoor or multi-cat households'},
    {'name': 'FeLV Booster', 'weeks': 13, 'isCore': false, 'freq': 'Annual', 'desc': 'Second dose of FeLV primary series'},
    {'name': 'Annual FVRCP Booster (Adult)', 'months': 15, 'isCore': true, 'freq': 'Every 1–3 years', 'desc': 'Adult maintenance booster'},
    {'name': 'FIV (Feline Immunodeficiency Virus)', 'months': 4, 'isCore': false, 'freq': 'Discuss with vet', 'desc': 'For outdoor/fighting cats at high risk'},
  ];

  // ── Rabbit schedule ─────────────────────────────────────────────────
  static const List<Map<String, dynamic>> _rabbitSchedule = [
    {'name': 'RHD1 (Rabbit Haemorrhagic Disease Type 1)', 'weeks': 10, 'isCore': true, 'freq': 'Annual', 'desc': 'Core rabbit vaccine – deadly viral disease'},
    {'name': 'RHD2 (Rabbit Haemorrhagic Disease Type 2)', 'weeks': 12, 'isCore': true, 'freq': 'Annual', 'desc': 'New strain – annual booster essential'},
    {'name': 'Myxomatosis', 'weeks': 6, 'isCore': true, 'freq': 'Annual (every 6 months in high-risk areas)', 'desc': 'Core vaccine – fatal without vaccination'},
    {'name': 'Annual Booster (Myxo + RHD)', 'months': 13, 'isCore': true, 'freq': 'Annual', 'desc': 'Adult maintenance combo'},
  ];

  /// Returns recommended vaccines for a pet based on type and age in months
  static List<Map<String, dynamic>> getRecommendations(String petType, double ageInMonths) {
    List<Map<String, dynamic>> schedule;

    switch (petType.toLowerCase()) {
      case 'dog':
        schedule = _dogSchedule;
        break;
      case 'cat':
        schedule = _catSchedule;
        break;
      case 'rabbit':
        schedule = _rabbitSchedule;
        break;
      default:
        return [];
    }

    final List<Map<String, dynamic>> results = [];

    for (final vaccine in schedule) {
      double dueAtMonths;
      if (vaccine.containsKey('weeks')) {
        dueAtMonths = (vaccine['weeks'] as int) / 4.33;
      } else {
        dueAtMonths = (vaccine['months'] as int).toDouble();
      }

      // Show vaccines due within next 3 months or already overdue
      final diff = dueAtMonths - ageInMonths;
      if (diff >= -1 && diff <= 3) {
        results.add({
          ...vaccine,
          'dueAtMonths': dueAtMonths,
          'isOverdue': diff < 0,
          'dueInMonths': diff,
        });
      }
    }

    return results;
  }

  /// Get the full schedule for display on profile
  static List<Map<String, dynamic>> getFullSchedule(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog': return _dogSchedule;
      case 'cat': return _catSchedule;
      case 'rabbit': return _rabbitSchedule;
      default: return [];
    }
  }
}
