// lib/screens/owner/owner_pets_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/pet_model.dart';
import '../../services/database_service.dart';

class OwnerPetsScreen extends StatefulWidget {
  final String uid;
  const OwnerPetsScreen({super.key, required this.uid});
  @override
  State<OwnerPetsScreen> createState() => _OwnerPetsScreenState();
}

class _OwnerPetsScreenState extends State<OwnerPetsScreen> {
  final _db = DatabaseService();

  void _showForm([Pet? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final ageCtrl = TextEditingController(text: existing?.age.toString() ?? '');
    final weightCtrl = TextEditingController(text: existing?.weight.toString() ?? '');
    String type = existing?.type ?? 'Dog';
    String gender = existing?.gender ?? 'Male';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(existing == null ? 'Add New Pet' : 'Edit Pet', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Pet Name *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Fish', 'Other'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setM(() => type = v!),
              )),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setM(() => gender = v!),
              )),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age (years)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AC.violet, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final pet = Pet(id: existing?.id ?? '', ownerId: widget.uid, name: nameCtrl.text.trim(), type: type, age: double.tryParse(ageCtrl.text) ?? 0, weight: double.tryParse(weightCtrl.text) ?? 0, gender: gender);
                if (existing == null) { await _db.addPet(pet); } else { await _db.updatePet(pet); }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Save Pet' : 'Update Pet', style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Pets', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AC.bg, foregroundColor: AC.text1, elevation: 0),
      body: StreamBuilder<List<Pet>>(
        stream: _db.getUserPets(widget.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final pets = snap.data ?? [];
          if (pets.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('🐾', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('No pets yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Add your first pet to get started', style: TextStyle(color: AC.text3)),
          ]));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, i) {
              final pet = pets[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      CircleAvatar(radius: 30, backgroundColor: const Color(0xFFEFF6FF), child: const Text('🐾', style: TextStyle(fontSize: 24))),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(pet.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(pet.type, style: const TextStyle(color: AC.text3)),
                      ])),
                      IconButton(icon: const Icon(Icons.edit, color: AC.text3), onPressed: () => _showForm(pet)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _db.deletePet(pet.id)),
                    ]),
                    const Divider(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _stat('Age', '${pet.age} yrs'),
                      _stat('Weight', '${pet.weight} kg'),
                      _stat('Gender', pet.gender),
                    ]),
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
        label: const Text('Add Pet', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 12, color: AC.text3)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
  ]);
}
