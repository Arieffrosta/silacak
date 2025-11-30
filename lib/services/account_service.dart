import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Ambil data user dari Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  /// Update profil user di Firestore
  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User belum login");

    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'phone': phone,
      'address': address,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Perbarui displayName di FirebaseAuth juga (opsional)
    await user.updateDisplayName(name);
  }
}
