import 'package:app_silacak/models/module_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModuleService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addModule(ModuleModel module) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User belum login');

    await _firestore.collection('modules').doc(module.id).set({
      'id': module.id,
      'plate': module.plate,
      'type': module.type,
      'status': module.status,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getModulesByUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot =
        await _firestore
            .collection('modules')
            .where('userId', isEqualTo: userId)
            .get();

    return snapshot.docs.map((d) => d.data()).toList();
  }

  Future<void> updateModule(ModuleModel module) async {
    await _firestore
        .collection('modules')
        .doc(module.id)
        .update(module.toMap());
  }

  Future<void> deleteModule(String id) async {
    await _firestore.collection('modules').doc(id).delete();
  }

  // =======================================================
  // 🔵 Fungsi tambahan: Ambil module berdasarkan ID + validasi user
  // =======================================================
  Future<Map<String, dynamic>?> getModuleById(String moduleId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User belum login");

    final doc = await _firestore.collection('modules').doc(moduleId).get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    // Validasi module milik user login
    if (data['userId'] != userId) {
      throw Exception("Module bukan milik user ini!");
    }

    return data;
  }
}
