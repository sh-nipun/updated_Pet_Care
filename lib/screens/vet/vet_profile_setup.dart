// lib/screens/vet/vet_profile_setup.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../models/vet_profile_model.dart';
import '../../models/user_model.dart';

class VetProfileSetup extends StatefulWidget {
  final String uid;
  const VetProfileSetup({super.key, required this.uid});
  @override
  State<VetProfileSetup> createState() => _VetProfileSetupState();
}

class _VetProfileSetupState extends State<VetProfileSetup> {
  final _db = DatabaseService();
  final _phoneCtrl = TextEditingController();
  final _clinicCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();
  final _specCtrl = TextEditingController();
  String _startTime = '09:00';
  String _endTime = '18:00';
  List<String> _selectedDays = [];
  bool _loading = false;
  bool _profileLoaded = false;

  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final _timeSlots = ['06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _db.getVetProfile(widget.uid);
    if (profile != null && mounted) {
      setState(() {
        _phoneCtrl.text = profile.phone;
        _clinicCtrl.text = profile.clinicName;
        _addressCtrl.text = profile.address;
        _degreeCtrl.text = profile.degree;
        _specCtrl.text = profile.specialization;
        _startTime = profile.workStartTime;
        _endTime = profile.workEndTime;
        _selectedDays = List.from(profile.workingDays);
        _profileLoaded = true;
      });
    } else {
      setState(() => _profileLoaded = true);
    }
  }

  Future<void> _save() async {
    if (_degreeCtrl.text.trim().isEmpty || _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill degree and select working days')));
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await _db.getUser(widget.uid);
      final profile = VetProfile(
        uid: widget.uid,
        fullName: user?.fullName ?? '',
        email: user?.email ?? '',
        phone: _phoneCtrl.text.trim(),
        clinicName: _clinicCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        degree: _degreeCtrl.text.trim(),
        specialization: _specCtrl.text.trim(),
        workingDays: _selectedDays,
        workStartTime: _startTime,
        workEndTime: _endTime,
      );
      await _db.saveVetProfile(profile);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved! Awaiting admin approval.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose(); _clinicCtrl.dispose(); _addressCtrl.dispose();
    _degreeCtrl.dispose(); _specCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_profileLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AC.text1)),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: AC.text1), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: StreamBuilder<VetProfile?>(
        stream: _db.vetProfileStream(widget.uid),
        builder: (context, snap) {
          final isApproved = snap.data?.isApproved ?? false;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

              // Approval badge
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: isApproved ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isApproved ? Colors.green.shade200 : Colors.orange.shade200),
                ),
                child: Row(children: [
                  Icon(isApproved ? Icons.verified : Icons.pending, color: isApproved ? Colors.green : Colors.orange),
                  const SizedBox(width: 8),
                  Text(isApproved ? 'Profile Approved ✓' : 'Pending admin approval', style: TextStyle(color: isApproved ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 20),

              _section('Educational Qualifications'),
              _field(_degreeCtrl, 'Degree (e.g. BVSc & AH, MVSc)', Icons.school),
              const SizedBox(height: 10),
              _field(_specCtrl, 'Specialization (e.g. Small Animals, Surgery)', Icons.biotech),
              const SizedBox(height: 20),

              _section('Clinic Information'),
              _field(_clinicCtrl, 'Clinic Name', Icons.local_hospital),
              const SizedBox(height: 10),
              _field(_addressCtrl, 'Clinic Address', Icons.location_on),
              const SizedBox(height: 10),
              _field(_phoneCtrl, 'Phone Number', Icons.phone, type: TextInputType.phone),
              const SizedBox(height: 20),

              _section('Working Days'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _days.map((day) {
                  final sel = _selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () => setState(() { sel ? _selectedDays.remove(day) : _selectedDays.add(day); }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AC.violet : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? AC.violet : Colors.grey.shade300),
                      ),
                      child: Text(day.substring(0, 3), style: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _section('Working Hours'),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Start Time', style: TextStyle(fontSize: 12, color: AC.text3)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _startTime,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _startTime = v!),
                  ),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('End Time', style: TextStyle(fontSize: 12, color: AC.text3)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _endTime,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _endTime = v!),
                  ),
                ])),
              ]),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AC.violet,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AC.white, strokeWidth: 2))
                    : const Text('Save Profile', style: TextStyle(color: AC.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ]),
          );
        },
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AC.text3, letterSpacing: 1.1)),
  );

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType? type}) => TextField(
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AC.violet),
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: AC.white,
    ),
  );
}
