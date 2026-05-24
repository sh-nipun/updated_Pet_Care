// lib/screens/vet/vet_appointments.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/appointment_model.dart';

class VetAppointments extends StatefulWidget {
  final String uid;
  const VetAppointments({super.key, required this.uid});
  @override
  State<VetAppointments> createState() => _VetAppointmentsState();
}

class _VetAppointmentsState extends State<VetAppointments> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _db = DatabaseService();

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg,
        elevation: 0,
        title: const Text('Appointments', style: TextStyle(fontWeight: FontWeight.bold, color: AC.text1)),
        bottom: TabBar(
          controller: _tab,
          labelColor: AC.violet,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AC.violet,
          tabs: const [Tab(text: 'New'), Tab(text: 'Accepted'), Tab(text: 'Completed')],
        ),
      ),
      body: StreamBuilder<List<AppointmentRequest>>(
        stream: _db.getVetAppointments(widget.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final all = snap.data ?? [];
          final newAppts = all.where((a) => a.status == 'confirmed').toList();
          final accepted = all.where((a) => a.status == 'accepted_vet').toList();
          final completed = all.where((a) => a.status == 'done').toList();

          return TabBarView(
            controller: _tab,
            children: [
              _ApptList(items: newAppts, type: 'new', db: _db),
              _ApptList(items: accepted, type: 'accepted', db: _db),
              _ApptList(items: completed, type: 'completed', db: _db),
            ],
          );
        },
      ),
    );
  }
}

class _ApptList extends StatelessWidget {
  final List<AppointmentRequest> items;
  final String type;
  final DatabaseService db;
  const _ApptList({required this.items, required this.type, required this.db});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final msg = type == 'new' ? 'No new requests' : type == 'accepted' ? 'No accepted appointments' : 'No completed appointments';
      return Center(child: Text(msg, style: const TextStyle(color: AC.text3)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) => _ApptCard(appt: items[i], type: type, db: db),
    );
  }
}

class _ApptCard extends StatelessWidget {
  final AppointmentRequest appt;
  final String type;
  final DatabaseService db;
  const _ApptCard({required this.appt, required this.type, required this.db});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(_petEmoji(appt.petType), style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appt.petName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Owner: ${appt.ownerName}', style: const TextStyle(color: AC.text3, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(appt.requestedDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(appt.requestedTime, style: const TextStyle(color: AC.text3, fontSize: 12)),
            ]),
          ]),

          if (appt.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.notes, size: 14, color: AC.text3),
                const SizedBox(width: 6),
                Expanded(child: Text(appt.notes, style: const TextStyle(fontSize: 12, color: AC.text3))),
              ]),
            ),
          ],

          // Vet notes for completed
          if (type == 'completed' && appt.vetNotes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Diagnosis & Solution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                const SizedBox(height: 4),
                Text(appt.vetNotes, style: const TextStyle(fontSize: 12)),
              ]),
            ),
          ],

          // Rating received
          if (type == 'completed' && appt.rating > 0) ...[
            const SizedBox(height: 8),
            Row(children: [
              ...List.generate(5, (i) => Icon(i < appt.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
              const SizedBox(width: 6),
              if (appt.ratingComment.isNotEmpty)
                Expanded(child: Text('"${appt.ratingComment}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AC.text3))),
            ]),
          ],

          const SizedBox(height: 14),

          // Action buttons
          if (type == 'new')
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => db.updateAppointmentStatus(appt.id, 'cancelled'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                child: const Text('Decline'),
              )),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(
                onPressed: () => db.updateAppointmentStatus(appt.id, 'accepted_vet'),
                style: ElevatedButton.styleFrom(backgroundColor: AC.violet),
                child: const Text('Accept', style: TextStyle(color: Colors.white)),
              )),
            ]),

          if (type == 'accepted')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text('Mark as Done', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () => _showDoneDialog(context),
              ),
            ),
        ]),
      ),
    );
  }

  String _petEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'dog': return '🐕';
      case 'cat': return '🐈';
      case 'bird': return '🐦';
      case 'rabbit': return '🐇';
      case 'fish': return '🐟';
      default: return '🐾';
    }
  }

  void _showDoneDialog(BuildContext context) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Appointment'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add your diagnosis and treatment notes for the pet owner:',
              style: TextStyle(color: AC.text3, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: notesCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'e.g. Diagnosed with mild ear infection. Prescribed Otomax drops twice daily for 7 days.',
              border: OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (notesCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please add diagnosis notes')));
                return;
              }
              await db.completeAppointment(appt.id, notesCtrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Complete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
