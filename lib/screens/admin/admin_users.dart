// lib/screens/admin/admin_users.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});
  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _db = DatabaseService();
  String _search = '';

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.violet,
        elevation: 0,
        title: const Text('Users', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'All'), Tab(text: 'Pet Owners'), Tab(text: 'Vets')],
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AC.white,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: _db.getAllUsers(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final all = snap.data ?? [];
              return TabBarView(
                controller: _tab,
                children: [
                  _UserList(users: _filter(all, null), db: _db, search: _search),
                  _UserList(users: _filter(all, 'pet_owner'), db: _db, search: _search),
                  _UserList(users: _filter(all, 'veterinarian'), db: _db, search: _search),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  List<UserModel> _filter(List<UserModel> users, String? role) {
    var list = role == null ? users : users.where((u) => u.role == role).toList();
    if (_search.isNotEmpty) {
      list = list.where((u) => u.fullName.toLowerCase().contains(_search) || u.email.toLowerCase().contains(_search)).toList();
    }
    return list;
  }
}

class _UserList extends StatelessWidget {
  final List<UserModel> users;
  final DatabaseService db;
  final String search;
  const _UserList({required this.users, required this.db, required this.search});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const Center(child: Text('No users found', style: TextStyle(color: AC.text3)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: users.length,
      itemBuilder: (context, i) {
        final u = users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _roleColor(u.role).withOpacity(0.15),
              child: Text(u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
                  style: TextStyle(color: _roleColor(u.role), fontWeight: FontWeight.bold)),
            ),
            title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(u.email, style: const TextStyle(fontSize: 12)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _roleColor(u.role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_roleLabel(u.role), style: TextStyle(color: _roleColor(u.role), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              if (!u.isAdmin) IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _confirmDelete(context, u),
              ),
            ]),
          ),
        );
      },
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return Colors.purple;
      case 'veterinarian': return Colors.blue;
      default: return Colors.green;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin': return 'Admin';
      case 'veterinarian': return 'Vet';
      default: return 'Owner';
    }
  }

  void _confirmDelete(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await db.deleteUser(user.uid);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
