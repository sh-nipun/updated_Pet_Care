// lib/screens/owner/owner_book_appointment.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/vet_profile_model.dart';
import '../../models/appointment_model.dart';
import '../../models/pet_model.dart';
import '../../models/user_model.dart';

class OwnerBookAppointment extends StatefulWidget {
  final String uid;
  const OwnerBookAppointment({super.key, required this.uid});
  @override
  State<OwnerBookAppointment> createState() => _OwnerBookAppointmentState();
}

class _OwnerBookAppointmentState extends State<OwnerBookAppointment> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

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
          tabs: const [Tab(text: 'Find a Vet'), Tab(text: 'My Bookings')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _VetListTab(uid: widget.uid),
          _MyBookingsTab(uid: widget.uid),
        ],
      ),
    );
  }
}

class _VetListTab extends StatelessWidget {
  final String uid;
  const _VetListTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    return StreamBuilder<List<VetProfile>>(
      stream: db.getApprovedVets(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final vets = snap.data ?? [];
        if (vets.isEmpty) return const Center(child: Text('No veterinarians available yet'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vets.length,
          itemBuilder: (context, i) => _VetCard(vet: vets[i], ownerUid: uid),
        );
      },
    );
  }
}

class _VetCard extends StatelessWidget {
  final VetProfile vet;
  final String ownerUid;
  const _VetCard({required this.vet, required this.ownerUid});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 28, backgroundColor: const Color(0xFFEFF6FF),
                child: const Icon(Icons.local_hospital, color: AC.violet, size: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(vet.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(vet.degree, style: const TextStyle(color: AC.text3, fontSize: 12)),
              Text(vet.specialization, style: const TextStyle(color: AC.violet, fontSize: 12)),
            ])),
            Column(children: [
              Row(children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(vet.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              Text('(${vet.totalRatings})', style: const TextStyle(color: AC.text3, fontSize: 11)),
            ]),
          ]),
          const Divider(height: 20),
          Row(children: [
            const Icon(Icons.schedule, size: 14, color: AC.text3),
            const SizedBox(width: 4),
            Expanded(child: Text(vet.availabilityText, style: const TextStyle(fontSize: 12, color: AC.text3))),
          ]),
          if (vet.clinicName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on, size: 14, color: AC.text3),
              const SizedBox(width: 4),
              Expanded(child: Text(vet.clinicName, style: const TextStyle(fontSize: 12, color: AC.text3))),
            ]),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showBookingForm(context, vet),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AC.violet,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Book Appointment', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showBookingForm(BuildContext context, VetProfile vet) {
    final db = DatabaseService();
    String? selectedPet;
    String? selectedPetType;
    DateTime? selectedDate;
    String? selectedTime;
    final notesCtrl = TextEditingController();
    String? ownerName;
    Set<String> bookedSlots = {};

    // Get owner name
    db.getUser(ownerUid).then((u) => ownerName = u?.fullName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Book with ${vet.fullName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Available: ${vet.availabilityText}', style: const TextStyle(color: AC.text3, fontSize: 12)),
              const SizedBox(height: 16),

              // Pet selector
              StreamBuilder<List<Pet>>(
                stream: db.getUserPets(ownerUid),
                builder: (context, snap) {
                  final pets = snap.data ?? [];
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Pet', border: OutlineInputBorder()),
                    value: selectedPet,
                    items: pets.map((p) => DropdownMenuItem(
                      value: p.name,
                      onTap: () => selectedPetType = p.type,
                      child: Text('${p.name} (${p.type})'),
                    )).toList(),
                    onChanged: (v) => setModal(() { selectedPet = v; }),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Date picker
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(selectedDate == null ? 'Pick Date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (d != null) {
                    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d.weekday - 1];
                    if (!vet.workingDays.contains(dayName)) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Vet is not available on $dayName')));
                      return;
                    }
                    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                    final fetched = await db.getBookedSlots(vet.uid, dateStr);
                    setModal(() {
                      selectedDate = d;
                      selectedTime = null;
                      bookedSlots = fetched;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Time picker (from vet's working hours)
              if (selectedDate != null) ...[
                const Text('Select Time Slot', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: _buildTimeSlots(vet).map((t) {
                  final sel = selectedTime == t;
                  final booked = bookedSlots.contains(t);
                  return GestureDetector(
                    onTap: booked ? null : () => setModal(() => selectedTime = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: booked
                            ? Colors.grey.shade200
                            : sel ? AC.violet : Colors.white,
                        border: Border.all(
                          color: booked
                              ? Colors.grey.shade300
                              : sel ? AC.violet : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          color: booked
                              ? Colors.grey.shade400
                              : sel ? Colors.white : Colors.black87,
                          fontSize: 13,
                          decoration: booked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 4),
                const Text('Strikethrough slots are already booked', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 12),
              ],

              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Reason / Notes (optional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AC.violet, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (selectedPet == null || selectedDate == null || selectedTime == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                    return;
                  }
                  final appt = AppointmentRequest(
                    id: '',
                    ownerId: ownerUid,
                    ownerName: ownerName ?? '',
                    vetId: vet.uid,
                    vetName: vet.fullName,
                    petName: selectedPet!,
                    petType: selectedPetType ?? '',
                    requestedDate: '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                    requestedTime: selectedTime!,
                    notes: notesCtrl.text.trim(),
                    status: 'pending_admin',
                  );
                  await db.createAppointment(appt);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment request sent! Awaiting admin confirmation.')));
                  }
                },
                child: const Text('Send Request', style: TextStyle(color: AC.white, fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }

  List<String> _buildTimeSlots(VetProfile vet) {
    final slots = <String>[];
    final startParts = vet.workStartTime.split(':');
    final endParts = vet.workEndTime.split(':');
    var h = int.parse(startParts[0]);
    final endH = int.parse(endParts[0]);
    while (h < endH) {
      slots.add('${h.toString().padLeft(2, '0')}:00');
      slots.add('${h.toString().padLeft(2, '0')}:30');
      h++;
    }
    return slots;
  }
}

class _MyBookingsTab extends StatelessWidget {
  final String uid;
  const _MyBookingsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    return StreamBuilder(
      stream: db.getOwnerAppointments(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final appts = snap.data ?? [];
        if (appts.isEmpty) return const Center(child: Text('No appointments yet'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appts.length,
          itemBuilder: (context, i) {
            final a = appts[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(a.vetName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    StatusPill(status: a.status),
                  ]),
                  const SizedBox(height: 4),
                  Text('${a.petName} · ${a.requestedDate} at ${a.requestedTime}', style: const TextStyle(color: AC.text3, fontSize: 12)),
                  if (a.notes.isNotEmpty) Text('Note: ${a.notes}', style: const TextStyle(fontSize: 12)),
                  if (a.status == 'done' && a.vetNotes.isNotEmpty) ...[
                    const Divider(),
                    Text('Vet Diagnosis: ${a.vetNotes}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                  if (a.status == 'done' && a.rating == 0) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.star_border, color: Colors.amber),
                        label: const Text('Rate this Vet', style: TextStyle(color: Colors.amber)),
                        onPressed: () => _showRating(context, a, db),
                      ),
                    ),
                  ],
                  if (a.rating > 0) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      ...List.generate(5, (idx) => Icon(idx < a.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
                      const SizedBox(width: 6),
                      Text(a.ratingComment, style: const TextStyle(fontSize: 11, color: AC.text3)),
                    ]),
                  ],
                ]),
              ),
            );
          },
        );
      },
    );
  }

  void _showRating(BuildContext context, appt, DatabaseService db) {
    double rating = 3;
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Rate ${appt.vetName}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(
              onTap: () => setS(() => rating = i + 1),
              child: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
            ))),
            const SizedBox(height: 12),
            TextField(controller: commentCtrl, decoration: const InputDecoration(hintText: 'Comment (optional)', border: OutlineInputBorder())),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AC.violet),
              onPressed: () async {
                await db.rateAppointment(appt.id, appt.vetId, rating, commentCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
      case 'accepted_vet': color = Colors.purple; label = 'Accepted'; break;
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
