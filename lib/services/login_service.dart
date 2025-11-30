import 'package:app_silacak/widgets/error_dialog.dart';
import 'package:app_silacak/widgets/success_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> handleLoginOrRegister(
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
      // mencoba login
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (context.mounted) {
        SuccessDialog.show(context, message: "Login berhasil!");
      }

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        // registrasi
        try {
          UserCredential userCred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          User? user = userCred.user;

          if (user != null) {
            final doc = _firestore.collection('users').doc(user.uid);
            final snapshot = await doc.get();
            if (!snapshot.exists) {
              await doc.set({
                'uid': user.uid,
                'email': user.email,
                'createdAt': FieldValue.serverTimestamp(),
                'tokenFCM': null,
              });
            }
          }

          if (context.mounted) {
            SuccessDialog.show(context, message: "Registrasi berhasil!");
          }

          return true;
        } on FirebaseAuthException catch (_) {
          if (context.mounted) {
            ErrorDialog.show(
              context,
              message: "Email sudah terdaftar/Password salah!",
            );
          }
          return false;
        }
      }

      if (e.code == 'weak-password') {
        if (context.mounted) {
          ErrorDialog.show(context, message: 'Password terlalu lemah');
        }
        return false;
      }

      if (context.mounted) {
        ErrorDialog.show(context, message: 'Error: ${e.message}');
      }
      return false;
    }
  }
}
