import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications(BuildContext context) async {
    // 🔹 Minta izin notifikasi
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Izin notifikasi diberikan');

      // 🔹 Inisialisasi notifikasi lokal
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
      );

      await _localNotifications.initialize(initSettings);

      // 🔹 Dapatkan token FCM
      final token = await _messaging.getToken();
      debugPrint('📱 Token FCM: $token');

      // 🔹 Simpan token ke Firestore jika user sedang login
      final user = _auth.currentUser;
      if (user != null && token != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        debugPrint(
          '💾 Token FCM disimpan ke Firestore untuk user: ${user.email}',
        );
      }

      // 🔹 Perbarui token otomatis
      _messaging.onTokenRefresh.listen((newToken) async {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'fcmToken': newToken,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          debugPrint('♻️ Token FCM diperbarui di Firestore');
        }
      });

      // 🔹 Listener pesan foreground (app sedang dibuka)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (message.notification != null) {
          final notification = message.notification!;
          final androidDetails = AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          );

          final platformDetails = NotificationDetails(android: androidDetails);
          await _localNotifications.show(
            0,
            notification.title,
            notification.body,
            platformDetails,
          );
        }
      });
    } else {
      debugPrint('❌ Izin notifikasi ditolak');
    }
  }
}
