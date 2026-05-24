// lib/screens/owner/owner_health_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/vaccination_model.dart';
import '../../models/medication_model.dart';
import '../../models/activity_model.dart';
import '../../models/pet_model.dart';
import '../../models/points_model.dart';
import '../../theme/app_theme.dart';

class OwnerHealthScreen extends StatefulWidget {
  final String uid;
  const OwnerHealthScreen({super.key, required this.uid});
  @override
  State<OwnerHealthScreen> createState() => _OwnerHealthScreenState();
}

class _OwnerHealthScreenState extends State<OwnerHealthScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg,
        elevation: 0,
        title: const Text('Health', style: TextStyle(fontWeight: FontWeight.w800, color: AC.text1)),
        bottom: TabBar(
          controller: _tab,
          labelColor: AC.violet,
          unselectedLabelColor: AC.text3,
          indicatorColor: AC.violet,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [Tab(text: 'Vaccines'), Tab(text: 'Medications'), Tab(text: 'Activities'), Tab(text: 'Schedule')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        _VaccinationTab(uid: widget.uid),
        _MedicationTab(uid: widget.uid),
        _ActivityTab(uid: widget.uid),
        _RecommendationsTab(uid: widget.uid),
      ]),
    );
  }
}

// ── VACCINATION TAB ───────────────────────────────────────────────────────────
class _VaccinationTab extends StatefulWidget {
  final String uid;
  const _VaccinationTab({required this.uid});
  @override
  State<_VaccinationTab> createState() => _VaccinationTabState();
}

class _VaccinationTabState extends State<_VaccinationTab> {
  final _db = DatabaseService();

  void _showForm([Vaccination? ex]) {
    final petCtrl = TextEditingController(text: ex?.petName ?? '');
    final vaccineCtrl = TextEditingController(text: ex?.vaccineName ?? '');
    DateTime dateTaken = ex?.dateTaken ?? DateTime.now();
    DateTime nextDue = ex?.nextDue ?? DateTime.now().add(const Duration(days: 365));

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(ex == null ? 'Add Vaccination' : 'Edit Vaccination', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: petCtrl, decoration: const InputDecoration(labelText: 'Pet Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: vaccineCtrl, decoration: const InputDecoration(labelText: 'Vaccine Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text('Date Taken: ${DateFormat('yyyy-MM-dd').format(dateTaken)}'),
              onPressed: () async {
                final d = await showDatePicker(context: ctx, initialDate: dateTaken, firstDate: DateTime(2000), lastDate: DateTime(2030));
                if (d != null) setM(() => dateTaken = d);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text('Next Due: ${DateFormat('yyyy-MM-dd').format(nextDue)}'),
              onPressed: () async {
                final d = await showDatePicker(context: ctx, initialDate: nextDue, firstDate: DateTime(2000), lastDate: DateTime(2035));
                if (d != null) setM(() => nextDue = d);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AC.violet, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                if (petCtrl.text.isEmpty || vaccineCtrl.text.isEmpty) return;
                final v = Vaccination(id: ex?.id ?? '', ownerId: widget.uid, petName: petCtrl.text.trim(), vaccineName: vaccineCtrl.text.trim(), dateTaken: dateTaken, nextDue: nextDue);
                if (ex == null) { await _db.addVaccination(v); } else { await _db.updateVaccination(v); }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(ex == null ? 'Add' : 'Update', style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
          ])),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Vaccination>>(
        stream: _db.getUserVaccinations(widget.uid),
        builder: (context, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('💉', style: TextStyle(fontSize: 60)), SizedBox(height: 12),
            Text('No vaccination records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final v = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: v.isOverdue ? Colors.red.shade50 : Colors.green.shade50,
                      child: Text(v.isOverdue ? '⚠️' : '✅')),
                  title: Text(v.vaccineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${v.petName} · Next due: ${DateFormat('dd MMM yyyy').format(v.nextDue)}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit, size: 18, color: AC.text2), onPressed: () => _showForm(v)),
                    IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent), onPressed: () => _db.deleteVaccination(v.id)),
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AC.violet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Record', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ── MEDICATION TAB ─────────────────────────────────────────────────────────────
class _MedicationTab extends StatefulWidget {
  final String uid;
  const _MedicationTab({required this.uid});
  @override
  State<_MedicationTab> createState() => _MedicationTabState();
}

class _MedicationTabState extends State<_MedicationTab> {
  final _db = DatabaseService();

  void _showForm([Medication? ex]) {
    final petCtrl = TextEditingController(text: ex?.petName ?? '');
    final nameCtrl = TextEditingController(text: ex?.medicationName ?? '');
    final dosageCtrl = TextEditingController(text: ex?.dosage ?? '');
    final timeCtrl = TextEditingController(text: ex?.scheduledTime ?? '');
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(ex == null ? 'Add Medication' : 'Edit Medication', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          TextField(controller: petCtrl, decoration: const InputDecoration(labelText: 'Pet Name', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medication Name', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: dosageCtrl, decoration: const InputDecoration(labelText: 'Dosage', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Scheduled Time', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AC.violet, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              final m = Medication(id: ex?.id ?? '', ownerId: widget.uid, petName: petCtrl.text.trim(), medicationName: nameCtrl.text.trim(), dosage: dosageCtrl.text.trim(), scheduledTime: timeCtrl.text.trim(), isTaken: ex?.isTaken ?? false);
              if (ex == null) { await _db.addMedication(m); } else { await _db.updateMedication(m); }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(ex == null ? 'Add' : 'Update', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Medication>>(
        stream: _db.getUserMedications(widget.uid),
        builder: (context, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('💊', style: TextStyle(fontSize: 60)), SizedBox(height: 12),
            Text('No medications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final m = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => _db.toggleMedicationTaken(m.id, !m.isTaken),
                    child: Container(width: 28, height: 28,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: m.isTaken ? const Color(0xFF22C55E) : Colors.transparent, border: Border.all(color: m.isTaken ? const Color(0xFF22C55E) : Colors.grey.shade400, width: 2)),
                      child: m.isTaken ? const Icon(Icons.check, color: AC.white, size: 16) : null),
                  ),
                  title: Text(m.medicationName, style: TextStyle(fontWeight: FontWeight.bold, decoration: m.isTaken ? TextDecoration.lineThrough : null)),
                  subtitle: Text('${m.petName} · ${m.dosage} · ${m.scheduledTime}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit, size: 18, color: AC.text2), onPressed: () => _showForm(m)),
                    IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent), onPressed: () => _db.deleteMedication(m.id)),
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AC.violet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Medication', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ── ACTIVITY TAB ────────────────────────────────────────────────────────────────
class _ActivityTab extends StatefulWidget {
  final String uid;
  const _ActivityTab({required this.uid});
  @override
  State<_ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<_ActivityTab> {
  final _db = DatabaseService();

  void _showForm() {
    final petCtrl = TextEditingController();
    final actCtrl = TextEditingController();
    final durCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AC.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Log Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AC.text1)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.stars_rounded, color: AC.amber, size: 16),
            const SizedBox(width: 6),
            const Text('Earn points for every activity logged!', style: TextStyle(color: AC.amber, fontSize: 12)),
          ]),
          const SizedBox(height: 16),
          TextField(controller: petCtrl, style: const TextStyle(color: AC.text1),
              decoration: const InputDecoration(labelText: 'Pet Name', prefixIcon: Icon(Icons.pets, color: AC.violet))),
          const SizedBox(height: 12),
          TextField(controller: actCtrl, style: const TextStyle(color: AC.text1),
              decoration: const InputDecoration(labelText: 'Activity (e.g. Walk, Chase, Swim)', prefixIcon: Icon(Icons.directions_run, color: AC.violet))),
          const SizedBox(height: 12),
          TextField(controller: durCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AC.text1),
              decoration: const InputDecoration(labelText: 'Duration (minutes)', prefixIcon: Icon(Icons.timer_outlined, color: AC.violet))),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AC.violet, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () async {
              if (actCtrl.text.isEmpty) return;
              final dur = int.tryParse(durCtrl.text) ?? 0;
              final a = Activity(id: '', ownerId: widget.uid, petName: petCtrl.text.trim(),
                  activityName: actCtrl.text.trim(), durationMinutes: dur, date: DateTime.now());
              await _db.addActivity(a);
              // Award points
              final user = await _db.getUser(widget.uid);
              await _db.awardActivityPoints(widget.uid, user?.fullName ?? '', dur);
              final pts = UserPoints.calcPoints(dur);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: AC.emerald,
                  content: Row(children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text('+$pts points earned! Keep it up!', style: const TextStyle(color: AC.white, fontWeight: FontWeight.w700)),
                  ]),
                ));
              }
            },
            child: const Text('Log & Earn Points', style: TextStyle(color: AC.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      body: StreamBuilder<List<Activity>>(
        stream: _db.getUserActivities(widget.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AC.violet));
          final items = snap.data ?? [];
          return Column(children: [
            // Points summary bar
            StreamBuilder<UserPoints?>(
              stream: _db.getUserPoints(widget.uid),
              builder: (context, ptSnap) {
                final pts = ptSnap.data;
                if (pts == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: AC.gHero, borderRadius: BorderRadius.circular(18)),
                  child: Row(children: [
                    Text(pts.tierEmoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${pts.totalPoints} Total Points', style: const TextStyle(color: AC.white, fontWeight: FontWeight.w800, fontSize: 18)),
                      Text('${pts.activitiesCompleted} activities completed · ${pts.tier} tier', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: const Text('2 pts/min', style: TextStyle(color: AC.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                );
              },
            ),
            Expanded(child: items.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('🏃', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 12),
                  Text('No activities yet', style: TextStyle(color: AC.text2, fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('Log an activity to earn points!', style: TextStyle(color: AC.text3)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final a = items[i];
                    final pts = UserPoints.calcPoints(a.durationMinutes);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AC.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(children: [
                        Container(width: 44, height: 44,
                          decoration: BoxDecoration(color: AC.violet.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Text('🏃', style: TextStyle(fontSize: 20)))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a.activityName, style: const TextStyle(color: AC.text1, fontWeight: FontWeight.w700)),
                          Text('${a.petName} · ${a.durationMinutes} min · ${DateFormat('dd MMM').format(a.date)}', style: const TextStyle(color: AC.text3, fontSize: 12)),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AC.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text('+$pts pts', style: const TextStyle(color: AC.amber, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                        const SizedBox(width: 4),
                        IconButton(icon: const Icon(Icons.delete_outline, color: AC.text3, size: 18), onPressed: () => _db.deleteActivity(a.id)),
                      ]),
                    );
                  },
                )),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showForm,
        backgroundColor: AC.violet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Activity', style: TextStyle(color: AC.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── RECOMMENDATIONS TAB ────────────────────────────────────────────────────────
class _RecommendationsTab extends StatelessWidget {
  final String uid;
  const _RecommendationsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    return StreamBuilder<List<Pet>>(
      stream: db.getUserPets(uid),
      builder: (context, petsSnap) {
        final pets = petsSnap.data ?? [];
        if (pets.isEmpty) {
          return const Center(child: Text('Add a pet first to see vaccine recommendations'));
        }
        return StreamBuilder<Set<String>>(
          stream: db.completedScheduleItemsStream(uid),
          builder: (context, doneSnap) {
            final completed = doneSnap.data ?? {};
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Points hint banner ──────────────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AC.amberL,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AC.amber.withOpacity(0.35)),
                  ),
                  child: Row(children: [
                    const Text('🏆', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Mark vaccines as done: +20 pts  ·  Medications: +10 pts',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AC.text2),
                      ),
                    ),
                  ]),
                ),

                // ── Per-pet schedule ────────────────────────────────
                ...pets.expand((pet) {
                  final schedule = VaccineScheduleEngine.getFullSchedule(pet.type);
                  if (schedule.isEmpty) return <Widget>[];
                  final ageMonths = pet.age * 12;
                  return [
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 10),
                      child: Text(
                        '${pet.name} (${pet.type}, ${pet.age} yrs)',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AC.text1),
                      ),
                    ),
                    ...schedule.map((v) {
                      final itemKey = '${pet.id}_${v['name']}';
                      final isDone = completed.contains(itemKey);
                      final isVaccine = v['type'] != 'medication';

                      final double dueAtMonths = v.containsKey('weeks')
                          ? (v['weeks'] as int) / 4.33
                          : (v['months'] as int).toDouble();
                      final diff = dueAtMonths - ageMonths;

                      // Card background colour
                      Color cardBg;
                      String timing;
                      if (isDone) {
                        cardBg = AC.emeraldL;
                        timing = 'Done ✓';
                      } else if (diff < 0) {
                        cardBg = AC.coralL;
                        timing = 'Overdue';
                      } else if (diff <= 3) {
                        cardBg = AC.amberL;
                        timing = 'Due soon';
                      } else {
                        cardBg = AC.emeraldL.withOpacity(0.5);
                        timing = 'Upcoming';
                      }

                      // Dot colour
                      Color dotColor;
                      if (isDone)             dotColor = AC.emerald;
                      else if (v['isCore'] == true) dotColor = AC.sky;
                      else                    dotColor = AC.amber;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          // Core/optional dot
                          Container(
                            width: 8, height: 8,
                            margin: const EdgeInsets.only(right: 10, top: 3),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                          ),
                          // Text content
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                v['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDone ? AC.emerald : AC.text1,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  decorationColor: AC.emerald,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(v['desc'] as String,
                                  style: const TextStyle(fontSize: 11, color: AC.text2)),
                              Text(v['freq'] as String,
                                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AC.text3)),
                            ]),
                          ),
                          const SizedBox(width: 8),
                          // Timing badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AC.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              timing,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDone ? AC.emerald : AC.text2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Mark-as-done checkbox
                          GestureDetector(
                            onTap: isDone
                                ? null
                                : () async {
                                    final user = await db.getUser(uid);
                                    final pts = await db.markScheduleItemDone(
                                      uid,
                                      user?.fullName ?? '',
                                      itemKey,
                                      isVaccine,
                                    );
                                    if (pts > 0 && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AC.emerald,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                          content: Row(children: [
                                            const Text('⭐', style: TextStyle(fontSize: 18)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '+\$pts points! "${v['name']}" marked as done.',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                          ]),
                                        ),
                                      );
                                    }
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? AC.emerald : Colors.transparent,
                                border: Border.all(
                                  color: isDone ? AC.emerald : AC.text3,
                                  width: 2,
                                ),
                              ),
                              child: isDone
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                          ),
                        ]),
                      );
                    }),
                    const Divider(height: 28),
                  ];
                }),
              ],
            );
          },
        );
      },
    );
  }
}
