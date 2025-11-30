import 'package:app_silacak/views/account.dart';
import 'package:app_silacak/views/authentication/auth_wrapper.dart';
import 'package:app_silacak/views/authentication/login.dart';
import 'package:app_silacak/views/history.dart';
import 'package:app_silacak/views/home.dart';
import 'package:app_silacak/views/modul.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String root = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String history = '/history';
  static const String modules = '/modules';
  static const String account = '/account';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryPage());
      case modules:
        return MaterialPageRoute(builder: (_) => const ModulePage());
      case account:
        return MaterialPageRoute(builder: (_) => const AccountPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
