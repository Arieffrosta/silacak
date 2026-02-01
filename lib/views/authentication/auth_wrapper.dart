import 'package:app_silacak/views/authentication/login.dart';
import 'package:app_silacak/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_silacak/services/notification_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final NotificationService _notificationService = NotificationService();
  bool _isNotificationInit = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ USER LOGIN
        if (snapshot.hasData) {
          if (!_isNotificationInit) {
            _isNotificationInit = true;

            // 🔔 INIT FCM DI SINI
            _notificationService.initNotifications(context);

            debugPrint("🔥 NotificationService initialized");
          }

          return const HomePage();
        }

        // ❌ USER LOGOUT → RESET FLAG
        _isNotificationInit = false;
        return const LoginPage();
      },
    );
  }
}
