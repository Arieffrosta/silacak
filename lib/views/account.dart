import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_silacak/widgets/bottom_tabbar.dart';
import 'package:app_silacak/widgets/success_dialog.dart';
import 'package:app_silacak/services/account_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _accountService = AccountService();

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _accountService.getUserData();

    setState(() {
      userData = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    final email =
        FirebaseAuth.instance.currentUser?.email ??
        'Tidak ada email';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),

      body:
          userData == null

              ? const Center(
                  child: CircularProgressIndicator(),
                )

              : Column(
                  children: [

                    // =================================
                    // HEADER (LEBIH KECIL)
                    // =================================
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.fromLTRB(
                        24,
                        6,
                        24,
                        18,
                      ),

                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF0F172A),
                            Color(0xFF1D4ED8),
                          ],

                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),

                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),

                      child: SafeArea(
                        bottom: false,

                        child: Column(
                          children: [

                            // FOTO PROFIL
                            Container(
                              padding:
                                  const EdgeInsets.all(4),

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                border: Border.all(
                                  color: Colors.white24,
                                  width: 2,
                                ),
                              ),

                              child: CircleAvatar(
                                radius: 34,

                                backgroundColor:
                                    Colors.white
                                        .withOpacity(0.15),

                                child: const Icon(
                                  Icons.person,
                                  size: 42,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // EMAIL
                            Text(
                              email,

                              textAlign:
                                  TextAlign.center,

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 3),

                            const Text(
                              "Akun Pengguna",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =================================
                    // CONTENT
                    // =================================
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.all(16),

                        child: Column(
                          children: [

                            // =========================
                            // CARD PROFIL
                            // =========================
                            Container(
                              padding:
                                  const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius:
                                    BorderRadius.circular(
                                        28),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(
                                            0.05),

                                    blurRadius: 16,

                                    offset:
                                        const Offset(
                                            0, 8),
                                  ),
                                ],
                              ),

                              child: Column(
                                children: [

                                  _buildProfileItem(
                                    icon:
                                        Icons.person_outline,

                                    label:
                                        "Nama Lengkap",

                                    value:
                                        userData?['name'] ??
                                        '-',
                                  ),

                                  const SizedBox(
                                      height: 14),

                                  _buildProfileItem(
                                    icon: Icons
                                        .phone_android,

                                    label:
                                        "Nomor HP",

                                    value:
                                        userData?['phone'] ??
                                        '-',
                                  ),

                                  const SizedBox(
                                      height: 14),

                                  _buildProfileItem(
                                    icon: Icons
                                        .home_outlined,

                                    label:
                                        "Alamat",

                                    value:
                                        userData?['address'] ??
                                        '-',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // =========================
                            // BUTTON EDIT
                            // =========================
                            SizedBox(
                              width: double.infinity,
                              height: 54,

                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showEditAccountSheet(
                                    context,
                                    FirebaseAuth
                                        .instance
                                        .currentUser,
                                  );
                                },

                                icon: const Icon(
                                  Icons.edit,
                                ),

                                label: const Text(
                                  "Ubah Akun",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(
                                          0xFF2563EB),

                                  foregroundColor:
                                      Colors.white,

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                18),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // =========================
                            // BUTTON LOGOUT
                            // =========================
                            SizedBox(
                              width: double.infinity,
                              height: 54,

                              child: ElevatedButton.icon(
                                onPressed: () async {

                                  await FirebaseAuth
                                      .instance
                                      .signOut();

                                  if (context.mounted) {
                                    Navigator
                                        .pushReplacementNamed(
                                      context,
                                      '/',
                                    );
                                  }
                                },

                                icon: const Icon(
                                  Icons.logout,
                                ),

                                label: const Text(
                                  "Keluar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red,

                                  foregroundColor:
                                      Colors.white,

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

      bottomNavigationBar:
          const BottomTabbar(currentIndex: 4),
    );
  }

  // =================================
  // PROFILE ITEM
  // =================================
  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color:
                  const Color(0xFFE0E7FF),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  label,

                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isNotEmpty
                      ? value
                      : '-',

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =================================
  // EDIT ACCOUNT SHEET
  // =================================
  void _showEditAccountSheet(
    BuildContext context,
    User? user,
  ) {

    final nameController =
        TextEditingController(
      text:
          userData?['name'] ??
          user?.displayName ??
          '',
    );

    final phoneController =
        TextEditingController(
      text: userData?['phone'] ?? '',
    );

    final addressController =
        TextEditingController(
      text: userData?['address'] ?? '',
    );

    final emailController =
        TextEditingController(
      text: user?.email ?? '',
    );

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),

      builder: (context) {

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,

            bottom:
                MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                20,
          ),

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                Container(
                  width: 60,
                  height: 6,

                  decoration: BoxDecoration(
                    color:
                        Colors.grey.shade300,

                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Ubah Akun",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                _modernField(
                  controller:
                      nameController,

                  label:
                      "Nama Lengkap",

                  icon:
                      Icons.person_outline,
                ),

                const SizedBox(height: 16),

                _modernField(
                  controller:
                      emailController,

                  label: "Email",

                  icon:
                      Icons.email_outlined,

                  readOnly: true,
                ),

                const SizedBox(height: 16),

                _modernField(
                  controller:
                      phoneController,

                  label:
                      "Nomor HP",

                  icon: Icons
                      .phone_android,
                ),

                const SizedBox(height: 16),

                _modernField(
                  controller:
                      addressController,

                  label: "Alamat",

                  icon:
                      Icons.home_outlined,

                  maxLines: 2,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton.icon(
                    onPressed: () async {

                      await _accountService
                          .updateUserProfile(
                        name:
                            nameController
                                .text
                                .trim(),

                        phone:
                            phoneController
                                .text
                                .trim(),

                        address:
                            addressController
                                .text
                                .trim(),
                      );

                      if (context.mounted) {

                        Navigator.pop(
                            context);

                        SuccessDialog.show(
                          context,

                          message:
                              'Profil berhasil diperbarui!',
                        );

                        _loadUserData();
                      }
                    },

                    icon:
                        const Icon(Icons.save),

                    label: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF2563EB),

                      foregroundColor:
                          Colors.white,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // =================================
  // MODERN FIELD
  // =================================
  Widget _modernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
  }) {

    return TextField(
      controller: controller,

      readOnly: readOnly,

      maxLines: maxLines,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        filled: true,

        fillColor:
            const Color(0xFFF8FAFC),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  18),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}