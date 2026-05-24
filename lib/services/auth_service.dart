// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential?> signUpWithEmailPassword(
      String email, String password, String name, String role) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = result.user!;
    await _db.collection('users').doc(user.uid).set({
      'fullName': name,
      'email': email,
      'role': role, // 'pet_owner' | 'veterinarian' | 'admin'
      'createdAt': FieldValue.serverTimestamp(),
    });
    return result;
  }

  Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async => await _auth.signOut();

  User? get currentUser => _auth.currentUser;
}
