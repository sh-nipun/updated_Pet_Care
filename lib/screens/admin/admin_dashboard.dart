// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../../models/appointment_model.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.violet,
        elevation: 0,
        title: const Row(children: [
          Icon(Icons.admin_panel_settings, color: Colors.white),
          SizedBox(width: 8),
          Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Stats row
          StreamBuilder<List<UserModel>>(
            stream: db.getAllUsers(),
            builder: (context, userSnap) {
              final users = userSnap.data ?? [];
              final owners = users.where((u) => u.isPetOwner).length;
              final vets = users.where((u) => u.isVet).length;
              return Row(children: [
                _StatCard(label: 'Total Users', value: '${users.length}', icon: Icons.people, color: Colors.blue),
                const SizedBox(width: 10),
                _StatCard(label: 'Pet Owners', value: '$owners', icon: Icons.pets, color: Colors.green),
                const SizedBox(width: 10),
                _StatCard(label: 'Vets', value: '$vets', icon: Icons.local_hospital, color: Colors.orange),
              ]);
            },
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<AppointmentRequest>>(
            stream: db.getAllAppointments(),
            builder: (context, apptSnap) {
              final appts = apptSnap.data ?? [];
              final pending = appts.where((a) => a.status == 'pending_admin').length;
              final done = appts.where((a) => a.status == 'done').length;
              return Row(children: [
                _StatCard(label: 'Total Appts', value: '${appts.length}', icon: Icons.calendar_today, color: Colors.purple),
                const SizedBox(width: 10),
                _StatCard(label: 'Pending', value: '$pending', icon: Icons.pending_actions, color: Colors.red),
                const SizedBox(width: 10),
                _StatCard(label: 'Completed', value: '$done', icon: Icons.check_circle, color: Colors.teal),
              ]);
            },
          ),
          const SizedBox(height: 24),

          // Pending appointments
          const Text('PENDING CONFIRMATIONS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AC.text3, letterSpacing: 1.1)),
          const SizedBox(height: 10),
          StreamBuilder<List<AppointmentRequest>>(
            stream: db.getAllAppointments(),
            builder: (context, snap) {
              final pending = (snap.data ?? []).where((a) => a.status == 'pending_admin').toList();
              if (pending.isEmpty) return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AC.white, borderRadius: BorderRadius.circular(12)),
                child: const Text('No pending appointments', style: TextStyle(color: AC.text3)),
              );
              return Column(children: pending.take(5).map((a) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AC.white, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.pending_actions, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${a.petName} → ${a.vetName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${a.ownerName} · ${a.requestedDate} ${a.requestedTime}', style: const TextStyle(color: AC.text3, fontSize: 12)),
                  ])),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () => db.updateAppointmentStatus(a.id, 'cancelled'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green, size: 20),
                      onPressed: () => db.updateAppointmentStatus(a.id, 'confirmed'),
                    ),
                  ]),
                ]),
              )).toList());
            },
          ),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AC.text3), textAlign: TextAlign.center),
      ]),
    ));
  }
}
