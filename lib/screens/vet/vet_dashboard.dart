// lib/screens/vet/vet_dashboard.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../models/vet_profile_model.dart';
import '../../models/appointment_model.dart';

class VetDashboard extends StatelessWidget {
  final String uid;
  const VetDashboard({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg,
        elevation: 0,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.local_hospital, color: AC.violet, size: 20),
          ),
          const SizedBox(width: 8),
          const Text('PetCare Vet', style: TextStyle(fontWeight: FontWeight.bold, color: AC.text1, fontSize: 18)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: AC.text1), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: StreamBuilder<VetProfile?>(
        stream: db.vetProfileStream(uid),
        builder: (context, vetSnap) {
          final vet = vetSnap.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: vet?.isApproved == true
                        ? [const Color(0xFF065F46), const Color(0xFF059669)]
                        : [const Color(0xFF92400E), const Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Hello, Dr. ${vet?.fullName.split(' ').first ?? ''}!',
                      style: const TextStyle(color: AC.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(vet?.isApproved == true ? Icons.verified : Icons.pending,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      vet?.isApproved == true
                          ? 'Profile approved – you are visible to pet owners'
                          : 'Awaiting admin approval – complete your profile below',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),

              // Rating card
              if (vet != null && vet.totalRatings > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AC.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Text('⭐', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(vet.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text('from ${vet.totalRatings} rating${vet.totalRatings > 1 ? 's' : ''}', style: const TextStyle(color: AC.text3)),
                    ]),
                    const Spacer(),
                    Row(children: List.generate(5, (i) => Icon(
                      i < vet.rating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber, size: 20,
                    ))),
                  ]),
                ),
                const SizedBox(height: 20),
              ],

              // Upcoming appointments
              const Text('UPCOMING APPOINTMENTS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AC.text3, letterSpacing: 1.1)),
              const SizedBox(height: 10),
              StreamBuilder<List<AppointmentRequest>>(
                stream: db.getVetAppointments(uid),
                builder: (context, snap) {
                  final all = snap.data ?? [];
                  final upcoming = all.where((a) =>
                      a.status == 'confirmed' || a.status == 'accepted_vet').toList();

                  if (upcoming.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AC.white, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('No upcoming appointments', style: TextStyle(color: AC.text3))),
                    );
                  }

                  return Column(children: upcoming.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AC.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.pets, color: AC.violet),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.petName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${a.ownerName} · ${a.requestedDate} at ${a.requestedTime}',
                            style: const TextStyle(color: AC.text3, fontSize: 12)),
                      ])),
                      StatusPill(status: a.status),
                    ]),
                  )).toList());
                },
              ),
            ]),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'confirmed': color = Colors.blue; label = 'Confirmed'; break;
      case 'accepted_vet': color = Colors.purple; label = 'Accepted'; break;
      case 'done': color = Colors.green; label = 'Done'; break;
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
