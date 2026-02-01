import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class GPSService {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>?> getGPSByModuleId(String moduleId) async {
    debugPrint("=== GET GPS DATA ===");
    debugPrint("Module ID: $moduleId");

    try {
      final path = "devices/$moduleId/";
      debugPrint("Mengambil RTDB path: $path");

      final snapshot = await db.child(path).get();

      if (!snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      final lat = (data["latitude"] as num?)?.toDouble();
      final lng = (data["longitude"] as num?)?.toDouble();

      debugPrint("📌 GPS Data: lat=$lat, lng=$lng");

      return {"latitude": lat, "longitude": lng};
    } catch (e) {
      debugPrint("❌ ERROR GET GPS: $e");
      return null;
    }
  }
}
