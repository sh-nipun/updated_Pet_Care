// lib/screens/admin/admin_appointments.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/appointment_model.dart';

class AdminAppointments extends StatefulWidget {
  const AdminAppointments({super.key});
  @override
  State<AdminAppointments> createState() => _AdminAppointmentsState();
}

class _AdminAppointmentsState extends State<AdminAppointments> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _db = DatabaseService();

  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.violet,
        elevation: 0,
        title: const Text('Appointments', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Confirmed'), Tab(text: 'Completed'), Tab(text: 'All')],
        ),
      ),
      body: StreamBuilder<List<AppointmentRequest>>(
        stream: _db.getAllAppointments(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final all = snap.data ?? [];
          return TabBarView(
            controller: _tab,
            children: [
              _ApptList(items: all.where((a) => a.status == 'pending_admin').toList(), db: _db, showActions: true),
              _ApptList(items: all.where((a) => a.status == 'confirmed' || a.status == 'accepted_vet').toList(), db: _db),
              _ApptList(items: all.where((a) => a.status == 'done').toList(), db: _db),
              _ApptList(items: all, db: _db),
            ],
          );
        },
      ),
    );
  }
}

class _ApptList extends StatelessWidget {
  final List<AppointmentRequest> items;
  final DatabaseService db;
  final bool showActions;
  const _ApptList({required this.items, required this.db, this.showActions = false});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('No appointments', style: TextStyle(color: AC.text3)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) => _AdminApptCard(appt: items[i], db: db, showActions: showActions),
    );
  }
}

class _AdminApptCard extends StatelessWidget {
  final AppointmentRequest appt;
  final DatabaseService db;
  final bool showActions;
  const _AdminApptCard({required this.appt, required this.db, required this.showActions});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${appt.petName} (${appt.petType})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('Owner: ${appt.ownerName}', style: const TextStyle(color: AC.text3, fontSize: 12)),
            ])),
            StatusPill(status: appt.status),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.local_hospital, size: 14, color: AC.text3),
            const SizedBox(width: 4),
            Text(appt.vetName, style: const TextStyle(fontSize: 13)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.schedule, size: 14, color: AC.text3),
            const SizedBox(width: 4),
            Text('${appt.requestedDate} at ${appt.requestedTime}', style: const TextStyle(fontSize: 13)),
          ]),
          if (appt.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Note: ${appt.notes}', style: const TextStyle(fontSize: 12, color: AC.text3)),
          ],
          if (appt.status == 'done' && appt.vetNotes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text('Diagnosis: ${appt.vetNotes}', style: const TextStyle(fontSize: 12, color: Colors.green)),
            ),
          ],
          if (appt.rating > 0) ...[
            const SizedBox(height: 6),
            Row(children: [
              ...List.generate(5, (i) => Icon(i < appt.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 14)),
              const SizedBox(width: 6),
              Text(appt.ratingComment, style: const TextStyle(fontSize: 11, color: AC.text3)),
            ]),
          ],

          if (showActions) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => _confirmAction(context, false),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                child: const Text('Reject'),
              )),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(
                onPressed: () => _confirmAction(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AC.violet),
                child: const Text('Confirm', style: TextStyle(color: Colors.white)),
              )),
            ]),
          ],

          if (!showActions && appt.status != 'done' && appt.status != 'cancelled') ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
                label: const Text('Cancel Appointment', style: TextStyle(color: Colors.red, fontSize: 12)),
                onPressed: () => db.updateAppointmentStatus(appt.id, 'cancelled'),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  void _confirmAction(BuildContext context, bool approve) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? 'Confirm Appointment' : 'Reject Appointment'),
        content: Text(approve
            ? 'Confirm appointment for ${appt.petName} with ${appt.vetName} on ${appt.requestedDate}?'
            : 'Reject this appointment request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: approve ? AC.violet : Colors.red),
            onPressed: () async {
              await db.updateAppointmentStatus(appt.id, approve ? 'confirmed' : 'cancelled');
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(approve ? 'Confirm' : 'Reject', style: const TextStyle(color: Colors.white)),
          ),
        ],
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
      case 'pending_admin': color = Colors.orange; label = 'Pending'; break;
      case 'confirmed': color = Colors.blue; label = 'Confirmed'; break;
      case 'accepted_vet': color = Colors.purple; label = 'Vet Accepted'; break;
      case 'done': color = Colors.green; label = 'Done'; break;
      case 'cancelled': color = Colors.red; label = 'Cancelled'; break;
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
