import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class GPSService {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>?> getGPSByModuleId(String moduleId) async {
    debugPrint("=== GET GPS DATA ===");
    debugPrint("Module ID: $moduleId");

    try {
      final path = "devices/$moduleId/gps";
      debugPrint("Mengambil RTDB path: $path");

      final snapshot = await db.child(path).get();

      if (!snapshot.exists) {
        // debugPrint("❌ Data GPS tidak ditemukan pada RTDB!");
        return null;
      }

      // debugPrint("📌 RTDB SNAPSHOT: ${snapshot.value}");

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      // debugPrint("📌 GPS Data finalized: $data");

      return {"latitude": data["latitude"], "longitude": data["longitude"]};
    } catch (e) {
      debugPrint("❌ ERROR GET GPS: $e");
      return null;
    }
  }
}
