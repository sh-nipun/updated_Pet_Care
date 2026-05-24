// lib/screens/admin/admin_vets.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/vet_profile_model.dart';

class AdminVets extends StatelessWidget {
  const AdminVets({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.violet,
        elevation: 0,
        title: const Text('Veterinarians', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: StreamBuilder<List<VetProfile>>(
        stream: db.getAllVets(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final vets = snap.data ?? [];
          if (vets.isEmpty) return const Center(child: Text('No vet profiles yet', style: TextStyle(color: AC.text3)));

          final pending = vets.where((v) => !v.isApproved).toList();
          final approved = vets.where((v) => v.isApproved).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                const Text('PENDING APPROVAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.1)),
                const SizedBox(height: 8),
                ...pending.map((v) => _VetCard(vet: v, db: db)),
                const SizedBox(height: 20),
              ],
              if (approved.isNotEmpty) ...[
                const Text('APPROVED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 1.1)),
                const SizedBox(height: 8),
                ...approved.map((v) => _VetCard(vet: v, db: db)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _VetCard extends StatelessWidget {
  final VetProfile vet;
  final DatabaseService db;
  const _VetCard({required this.vet, required this.db});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(vet.fullName.isNotEmpty ? vet.fullName[0].toUpperCase() : 'V',
                  style: const TextStyle(color: AC.violet, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(vet.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(vet.email, style: const TextStyle(color: AC.text3, fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vet.isApproved ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: vet.isApproved ? Colors.green : Colors.orange),
              ),
              child: Text(vet.isApproved ? 'Approved' : 'Pending',
                  style: TextStyle(color: vet.isApproved ? Colors.green.shade700 : Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ]),
          const Divider(height: 20),

          // Details
          if (vet.degree.isNotEmpty) _row(Icons.school, vet.degree),
          if (vet.specialization.isNotEmpty) _row(Icons.biotech, vet.specialization),
          if (vet.clinicName.isNotEmpty) _row(Icons.local_hospital, vet.clinicName),
          if (vet.address.isNotEmpty) _row(Icons.location_on, vet.address),
          if (vet.workingDays.isNotEmpty) _row(Icons.schedule, vet.availabilityText),
          if (vet.phone.isNotEmpty) _row(Icons.phone, vet.phone),

          if (vet.totalRatings > 0) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text('${vet.rating.toStringAsFixed(1)} (${vet.totalRatings} ratings)', style: const TextStyle(fontSize: 13)),
            ]),
          ],

          const SizedBox(height: 14),
          Row(children: [
            if (!vet.isApproved) Expanded(child: ElevatedButton.icon(
              icon: const Icon(Icons.verified, color: AC.white, size: 16),
              label: const Text('Approve', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => db.approveVet(vet.uid, true),
            )),
            if (vet.isApproved) Expanded(child: OutlinedButton.icon(
              icon: const Icon(Icons.block, color: Colors.red, size: 16),
              label: const Text('Revoke', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              onPressed: () => _confirmRevoke(context),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Icon(icon, size: 14, color: AC.text3),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AC.text3))),
    ]),
  );

  void _confirmRevoke(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Approval'),
        content: Text('Remove ${vet.fullName} from the approved vets list? They will no longer be visible to pet owners.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async { await db.approveVet(vet.uid, false); if (ctx.mounted) Navigator.pop(ctx); },
            child: const Text('Revoke', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
