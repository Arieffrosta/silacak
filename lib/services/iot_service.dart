import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class IoTService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance;

  Future<Map<String, dynamic>?> getIoTByModule(String moduleId) async {
    debugPrint("=== GET IoT DATA ===");
    debugPrint("Module ID: $moduleId");

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("❌ User belum login!");
      throw Exception("User belum login");
    }
    debugPrint("User ID: ${user.uid}");

    // VALIDASI MODULE
    final moduleDoc =
        await _firestore.collection("modules").doc(moduleId).get();
    if (!moduleDoc.exists) {
      debugPrint("❌ Module tidak ditemukan di Firestore!");
      throw Exception("Module tidak ditemukan");
    }

    debugPrint("Module ditemukan: ${moduleDoc.data()}");

    final moduleUser = moduleDoc.data()!["userId"];
    debugPrint("Module userId: $moduleUser");

    if (moduleUser != user.uid) {
      debugPrint("❌ Module bukan milik user ini!");
      throw Exception("Module bukan milik user ini");
    }

    // GET REALTIME DB
    final path = "devices/$moduleId";
    debugPrint("Mengambil RTDB path: $path");

    final snapshot = await _rtdb.ref(path).get();

    if (!snapshot.exists) {
      debugPrint("❌ Data IoT TIDAK DITEMUKAN di RTDB!");
      return null;
    }

    debugPrint("📌 RTDB SNAPSHOT: ${snapshot.value}");

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    debugPrint("📌 IoT Data finalized: $data");

    return data;
  }
}
