import 'package:app_silacak/views/account.dart';
import 'package:app_silacak/views/authentication/auth_wrapper.dart';
import 'package:app_silacak/views/authentication/login.dart';
import 'package:app_silacak/views/authentication/register_page.dart';
import 'package:app_silacak/views/authentication/forgot_password_page.dart';
import 'package:app_silacak/views/history.dart';
import 'package:app_silacak/views/home.dart';
import 'package:app_silacak/views/modul.dart';
import 'package:app_silacak/views/tracking_page.dart'; // 🔥 TAMBAHAN


import 'package:flutter/material.dart';

class Routes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String history = '/history';
  static const String tracking = '/tracking'; // 🔥 TAMBAHAN
  static const String modules = '/modules';
  static const String account = '/account';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case root:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case history:
        return MaterialPageRoute(builder: (_) => const HistoryPage());

      case tracking: // 🔥 INI YANG PENTING
        return MaterialPageRoute(builder: (_) => const TrackingPage());

      case modules:
        return MaterialPageRoute(builder: (_) => const ModulePage());

      case account:
        return MaterialPageRoute(builder: (_) => const AccountPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                '404 - Halaman tidak ditemukan',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
    }
  }
}