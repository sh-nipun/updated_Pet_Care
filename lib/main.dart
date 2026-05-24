// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/owner/owner_layout.dart';
import 'screens/vet/vet_layout.dart';
import 'screens/admin/admin_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PetCareApp());
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(backgroundColor: AC.bg, body: Center(child: CircularProgressIndicator(color: AC.violet)));
          }
          if (!snapshot.hasData) return const LoginScreen();
          return _RoleRouter(uid: snapshot.data!.uid);
        },
      ),
    );
  }
}

class _RoleRouter extends StatelessWidget {
  final String uid;
  const _RoleRouter({required this.uid});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: DatabaseService().userStream(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(backgroundColor: AC.bg, body: Center(child: CircularProgressIndicator(color: AC.violet)));
        }
        final user = snap.data;
        if (user == null) return const LoginScreen();
        if (user.isAdmin) return const AdminLayout();
        if (user.isVet) return VetLayout(uid: uid);
        return OwnerLayout(uid: uid);
      },
    );
  }
}
