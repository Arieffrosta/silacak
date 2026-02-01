import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'local_notification_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initNotifications(BuildContext context) async {
    // ✅ ANDROID 13+ PERMISSION
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    final token = await _fcm.getToken();
    debugPrint("📲 FCM TOKEN: $token");

    if (token != null) {
      await _saveTokenToFirestore(token);
    }

    // 🔥 FOREGROUND NOTIFICATION
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("🔔 Foreground: ${message.notification?.title}");

      if (message.notification != null) {
        LocalNotificationService.show(
          title: message.notification!.title ?? 'Notifikasi',
          body: message.notification!.body ?? '',
        );
      }
    });
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "fcmToken": token,
      "lastUpdated": FieldValue.serverTimestamp(),
    });
  }
}
