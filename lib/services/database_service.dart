// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/vet_profile_model.dart';
import '../models/appointment_model.dart';
import '../models/pet_model.dart';
import '../models/vaccination_model.dart';
import '../models/medication_model.dart';
import '../models/feeding_model.dart';
import '../models/activity_model.dart';
import '../models/points_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── USER ─────────────────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ── ADMIN: all users ─────────────────────────────────────────────────
  Stream<List<UserModel>> getAllUsers() {
    return _db.collection('users').snapshots().map((s) {
      final list = s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.fullName.compareTo(b.fullName));
      return list;
    });
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
    // Also delete vet profile if exists
    await _db.collection('vet_profiles').doc(uid).delete().catchError((_) {});
  }

  // ── VET PROFILES ─────────────────────────────────────────────────────
  Future<void> saveVetProfile(VetProfile profile) async {
    await _db.collection('vet_profiles').doc(profile.uid).set(profile.toMap());
  }

  Future<VetProfile?> getVetProfile(String uid) async {
    final doc = await _db.collection('vet_profiles').doc(uid).get();
    if (!doc.exists) return null;
    return VetProfile.fromMap(doc.data()!, doc.id);
  }

  Stream<VetProfile?> vetProfileStream(String uid) {
    return _db.collection('vet_profiles').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return VetProfile.fromMap(doc.data()!, doc.id);
    });
  }

  /// All approved vets (shown to pet owners when booking)
  Stream<List<VetProfile>> getApprovedVets() {
    return _db
        .collection('vet_profiles')
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => VetProfile.fromMap(d.data(), d.id)).toList());
  }

  /// All vets for admin (approved and pending)
  Stream<List<VetProfile>> getAllVets() {
    return _db.collection('vet_profiles').snapshots().map((s) {
      final list = s.docs.map((d) => VetProfile.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.fullName.compareTo(b.fullName));
      return list;
    });
  }

  Future<void> approveVet(String uid, bool approved) async {
    await _db.collection('vet_profiles').doc(uid).update({'isApproved': approved});
  }

  Future<void> updateVetRating(String vetId, double newRating) async {
    final doc = await _db.collection('vet_profiles').doc(vetId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final oldTotal = (data['totalRatings'] ?? 0) as int;
    final oldRating = (data['rating'] ?? 0).toDouble();
    final updatedTotal = oldTotal + 1;
    final updatedRating = ((oldRating * oldTotal) + newRating) / updatedTotal;
    await _db.collection('vet_profiles').doc(vetId).update({
      'rating': updatedRating,
      'totalRatings': updatedTotal,
    });
  }

  // ── APPOINTMENTS ─────────────────────────────────────────────────────
  Future<void> createAppointment(AppointmentRequest appt) async {
    await _db.collection('appointments').add(appt.toMap());
  }

  /// Pet owner sees their own appointments
  Stream<List<AppointmentRequest>> getOwnerAppointments(String ownerId) {
    return _db
        .collection('appointments')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => AppointmentRequest.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Vet sees appointments assigned to them (confirmed by admin)
  Stream<List<AppointmentRequest>> getVetAppointments(String vetId) {
    return _db
        .collection('appointments')
        .where('vetId', isEqualTo: vetId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => AppointmentRequest.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.requestedDate.compareTo(b.requestedDate));
      return list;
    });
  }

  /// Admin sees ALL appointments
  Stream<List<AppointmentRequest>> getAllAppointments() {
    return _db.collection('appointments').snapshots().map((s) {
      final list = s.docs.map((d) => AppointmentRequest.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await _db.collection('appointments').doc(id).update({'status': status});
  }

  Future<void> completeAppointment(String id, String vetNotes) async {
    await _db.collection('appointments').doc(id).update({
      'status': 'done',
      'vetNotes': vetNotes,
    });
  }

  Future<void> rateAppointment(String id, String vetId, double rating, String comment) async {
    await _db.collection('appointments').doc(id).update({
      'rating': rating,
      'ratingComment': comment,
    });
    await updateVetRating(vetId, rating);
  }

  Future<void> deleteAppointment(String id) async {
    await _db.collection('appointments').doc(id).delete();
  }

  /// Returns a set of time strings already booked for a vet on a given date
  /// (only active bookings: pending_admin, confirmed, accepted_vet)
  Future<Set<String>> getBookedSlots(String vetId, String date) async {
    final snap = await _db
        .collection('appointments')
        .where('vetId', isEqualTo: vetId)
        .where('requestedDate', isEqualTo: date)
        .get();
    return snap.docs
        .map((d) => AppointmentRequest.fromMap(d.data(), d.id))
        .where((a) => a.status != 'cancelled' && a.status != 'done')
        .map((a) => a.requestedTime)
        .toSet();
  }

  // ── PETS ─────────────────────────────────────────────────────────────
  Stream<List<Pet>> getUserPets(String userId) {
    return _db.collection('pets').where('ownerId', isEqualTo: userId).snapshots().map((s) {
      final list = s.docs.map((d) => Pet.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addPet(Pet pet) async => await _db.collection('pets').add(pet.toMap());
  Future<void> updatePet(Pet pet) async {
    final d = pet.toMap()..remove('createdAt');
    await _db.collection('pets').doc(pet.id).update(d);
  }
  Future<void> deletePet(String id) async => await _db.collection('pets').doc(id).delete();

  // ── VACCINATIONS ─────────────────────────────────────────────────────
  Stream<List<Vaccination>> getUserVaccinations(String userId) {
    return _db.collection('vaccinations').where('ownerId', isEqualTo: userId).snapshots().map((s) {
      final list = s.docs.map((d) => Vaccination.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addVaccination(Vaccination v) async => await _db.collection('vaccinations').add(v.toMap());
  Future<void> updateVaccination(Vaccination v) async {
    final d = v.toMap()..remove('createdAt');
    await _db.collection('vaccinations').doc(v.id).update(d);
  }
  Future<void> deleteVaccination(String id) async => await _db.collection('vaccinations').doc(id).delete();

  // ── MEDICATIONS ──────────────────────────────────────────────────────
  Stream<List<Medication>> getUserMedications(String userId) {
    return _db.collection('medications').where('ownerId', isEqualTo: userId).snapshots().map((s) {
      final list = s.docs.map((d) => Medication.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addMedication(Medication m) async => await _db.collection('medications').add(m.toMap());
  Future<void> updateMedication(Medication m) async {
    final d = m.toMap()..remove('createdAt');
    await _db.collection('medications').doc(m.id).update(d);
  }
  Future<void> deleteMedication(String id) async => await _db.collection('medications').doc(id).delete();
  Future<void> toggleMedicationTaken(String id, bool val) async =>
      await _db.collection('medications').doc(id).update({'isTaken': val});

  // ── FEEDINGS ─────────────────────────────────────────────────────────
  Stream<List<FeedingSchedule>> getUserFeedings(String userId) {
    return _db.collection('feedings').where('ownerId', isEqualTo: userId).snapshots().map((s) {
      final list = s.docs.map((d) => FeedingSchedule.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Future<void> addFeeding(FeedingSchedule f) async => await _db.collection('feedings').add(f.toMap());
  Future<void> updateFeeding(FeedingSchedule f) async {
    final d = f.toMap()..remove('createdAt');
    await _db.collection('feedings').doc(f.id).update(d);
  }
  Future<void> deleteFeeding(String id) async => await _db.collection('feedings').doc(id).delete();

  // ── ACTIVITIES ───────────────────────────────────────────────────────
  Stream<List<Activity>> getUserActivities(String userId) {
    return _db.collection('activities').where('ownerId', isEqualTo: userId).snapshots().map((s) {
      final list = s.docs.map((d) => Activity.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> addActivity(Activity a) async => await _db.collection('activities').add(a.toMap());
  Future<void> deleteActivity(String id) async => await _db.collection('activities').doc(id).delete();

  // ── POINTS & LEADERBOARD ─────────────────────────────────────────────
  Future<void> awardActivityPoints(String uid, String fullName, int durationMinutes) async {
    final pts = UserPoints.calcPoints(durationMinutes);
    final ref = _db.collection('points').doc(uid);
    final doc = await ref.get();
    if (doc.exists) {
      final current = doc.data()!;
      await ref.update({
        'totalPoints': (current['totalPoints'] ?? 0) + pts,
        'activitiesCompleted': (current['activitiesCompleted'] ?? 0) + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.set({
        'fullName': fullName,
        'totalPoints': pts,
        'activitiesCompleted': 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<UserPoints?> getUserPoints(String uid) {
    return _db.collection('points').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserPoints.fromMap(doc.data()!, doc.id);
    });
  }

  Stream<List<UserPoints>> getLeaderboard() {
    return _db.collection('points').snapshots().map((s) {
      final list = s.docs.map((d) => UserPoints.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
      return list;
    });
  }

  // ── SCHEDULE HEALTH COMPLETIONS ──────────────────────────────────────
  /// Live stream of which recommended items this user has already marked done.
  /// Key format: "{petId}_{vaccineName}"
  Stream<Set<String>> completedScheduleItemsStream(String uid) {
    return _db.collection('schedule_completions').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return <String>{};
      final raw = doc.data()?['completed'] as List<dynamic>? ?? [];
      return raw.cast<String>().toSet();
    });
  }

  /// Marks an item done once and awards points (vaccine = 20 pts, medication = 10 pts).
  /// Returns the points awarded, or 0 if it was already marked done before.
  Future<int> markScheduleItemDone(
      String uid, String fullName, String itemKey, bool isVaccine) async {
    final completionRef = _db.collection('schedule_completions').doc(uid);
    final doc = await completionRef.get();
    final existing = doc.exists
        ? ((doc.data()?['completed'] as List<dynamic>?) ?? []).cast<String>().toSet()
        : <String>{};
    if (existing.contains(itemKey)) return 0; // no double-award
    existing.add(itemKey);
    await completionRef.set({'completed': existing.toList()}, SetOptions(merge: true));

    final pts = isVaccine ? 20 : 10;
    final pointsRef = _db.collection('points').doc(uid);
    final pDoc = await pointsRef.get();
    if (pDoc.exists) {
      final cur = pDoc.data()!;
      await pointsRef.update({
        'totalPoints': (cur['totalPoints'] ?? 0) + pts,
        'activitiesCompleted': (cur['activitiesCompleted'] ?? 0) + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      await pointsRef.set({
        'fullName': fullName,
        'totalPoints': pts,
        'activitiesCompleted': 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
    return pts;
  }
}
