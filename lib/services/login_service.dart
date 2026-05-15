import 'package:app_silacak/widgets/error_dialog.dart';
import 'package:app_silacak/widgets/success_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔐 LOGIN SAJA
  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (!email.contains('@')) {
      if (context.mounted) {
        ErrorDialog.show(context, message: 'Format email tidak valid');
      }
      return false;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (context.mounted) {
        SuccessDialog.show(context, message: "Login berhasil!");
      }

      return true;
    } on FirebaseAuthException catch (e) {
      String message = "Login gagal";

      if (e.code == 'user-not-found') {
        message = "Email belum terdaftar";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = "Password salah";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid";
      }

      if (context.mounted) {
        ErrorDialog.show(context, message: message);
      }

      return false;
    }
  }

  /// 🆕 REGISTER SAJA
  Future<bool> register(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (!email.contains('@')) {
      if (context.mounted) {
        ErrorDialog.show(context, message: 'Format email tidak valid');
      }
      return false;
    }

    if (password.length < 6) {
      if (context.mounted) {
        ErrorDialog.show(context, message: 'Password minimal 6 karakter');
      }
      return false;
    }

    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCred.user;

      if (user != null) {
        final doc = _firestore.collection('users').doc(user.uid);
        await doc.set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'fcmToken': null,
        });
      }

      if (context.mounted) {
        SuccessDialog.show(context, message: "Registrasi berhasil!");
      }

      return true;
    } on FirebaseAuthException catch (e) {
      String message = "Registrasi gagal";

      if (e.code == 'email-already-in-use') {
        message = "Email sudah terdaftar";
      } else if (e.code == 'weak-password') {
        message = "Password terlalu lemah";
      }

      if (context.mounted) {
        ErrorDialog.show(context, message: message);
      }

      return false;
    }
  }
}