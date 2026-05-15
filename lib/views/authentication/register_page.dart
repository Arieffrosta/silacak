import 'package:animate_do/animate_do.dart';
import 'package:app_silacak/routes/routes.dart';
import 'package:app_silacak/services/login_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isObscure = true;
  bool isObscureConfirm = true;

  Future<void> _handleRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    /// 🔍 VALIDASI
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak sama")),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await LoginService().register(
      email,
      password,
      context,
    );

    setState(() => isLoading = false);

    if (success && mounted) {

      /// 🔥 WAJIB: LOGOUT BIAR TIDAK AUTO MASUK HOME
      await FirebaseAuth.instance.signOut();

      /// 🧹 CLEAR INPUT
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      /// 🔔 NOTIFIKASI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi berhasil, silakan login"),
        ),
      );

      /// 🚀 PINDAH KE LOGIN (BERSIHKAN STACK)
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [

              const SizedBox(height: 50),

              /// 🔵 HEADER
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: const [
                    Icon(Icons.person_add, size: 70, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      "Buat Akun",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Daftar untuk mulai menggunakan SiLacak",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// 🔹 CARD FORM
              FadeInUp(
                duration: const Duration(milliseconds: 900),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      /// EMAIL
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email, color: Colors.blue),
                          hintText: "Email",
                          filled: true,
                          fillColor: const Color(0xFFF1F4F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: isObscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                          hintText: "Password",
                          filled: true,
                          fillColor: const Color(0xFFF1F4F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// CONFIRM PASSWORD
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: isObscureConfirm,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
                          hintText: "Konfirmasi Password",
                          filled: true,
                          fillColor: const Color(0xFFF1F4F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscureConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isObscureConfirm = !isObscureConfirm;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// BUTTON REGISTER
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Daftar"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// BACK TO LOGIN
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.login,
                          );
                        },
                        child: const Text(
                          "Sudah punya akun? Login",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}