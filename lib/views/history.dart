import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_silacak/widgets/bottom_tabbar.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // ================================
  // OPEN GOOGLE MAP
  // ================================
  void openMap(double lat, double lng) async {
    final url =
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // ================================
  // DELETE ALL HISTORY
  // ================================
  Future<void> deleteAllHistory(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User belum login")),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final functions = FirebaseFunctions.instanceFor(
        region: 'asia-southeast1',
      );

      final callable = functions.httpsCallable(
        'deleteAllAccidents',
      );

      await callable.call({
        "userId": user.uid,
      });

      Navigator.pop(context);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Semua riwayat berhasil dihapus"),
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Gagal hapus riwayat"),
        ),
      );
    }
  }

  // ================================
  // CONFIRM DELETE
  // ================================
  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text("Hapus Semua Riwayat"),
        content: const Text(
          "Yakin ingin menghapus semua riwayat kecelakaan?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await deleteAllHistory(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),

      // ================================
      // MODERN HEADER
      // ================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),

        child: Container(
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
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),

          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: [

                  // ====================
                  // TITLE
                  // ====================
                  const Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          "Riwayat Kecelakaan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Data histori kecelakaan kendaraan",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ====================
                  // DELETE BUTTON
                  // ====================
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),

                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                      ),

                      onPressed: () =>
                          confirmDelete(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ================================
      // BODY
      // ================================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('accidents')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          // ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "❌ Error: ${snapshot.error}",
              ),
            );
          }

          // LOADING
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          // EMPTY
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 14),

                  Text(
                    "Belum ada riwayat kecelakaan",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: docs.length,

            itemBuilder: (context, index) {

              final data =
                  docs[index].data() as Map<String, dynamic>;

              final lat = (data['lat'] ?? 0).toDouble();
              final lng = (data['lng'] ?? 0).toDouble();
              final impact = data['magnitude'] ?? 0;

              final timestamp = data['createdAt'];

              DateTime date = DateTime.now();

              if (timestamp is Timestamp) {
                date = timestamp.toDate();
              }

              final gpsActive = lat != 0 && lng != 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Card(
                  elevation: 0,
                  color: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(22),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // ====================
                        // HEADER CARD
                        // ====================
                        Row(
                          children: [

                            Container(
                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),

                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  const Text(
                                    "Kecelakaan Terdeteksi",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "${date.day}/${date.month}/${date.year} "
                                    "${date.hour}:${date.minute.toString().padLeft(2, '0')}",

                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),

                              child: const Text(
                                "DARURAT",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ====================
                        // INFO BOX
                        // ====================
                        Container(
                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF8FAFC),
                                Color(0xFFEFF6FF),
                              ],
                            ),

                            borderRadius:
                                BorderRadius.circular(20),
                          ),

                          child: Column(
                            children: [

                              _buildInfoRow(
                                Icons.speed,
                                "Benturan",
                                "$impact G",
                              ),

                              const SizedBox(height: 16),

                              gpsActive
                                  ? _buildInfoRow(
                                      Icons.location_on,
                                      "Lokasi",
                                      "$lat, $lng",
                                    )
                                  : Row(
                                      children: [

                                        Container(
                                          padding:
                                              const EdgeInsets.all(
                                                  10),

                                          decoration: BoxDecoration(
                                            color:
                                                Colors.orange.shade50,

                                            borderRadius:
                                                BorderRadius.circular(
                                                    14),
                                          ),

                                          child: const Icon(
                                            Icons.gps_off,
                                            color: Colors.orange,
                                          ),
                                        ),

                                        const SizedBox(width: 14),

                                        const Expanded(
                                          child: Text(
                                            "GPS tidak aktif",
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ====================
                        // BUTTON
                        // ====================
                        if (gpsActive)
                          SizedBox(
                            width: double.infinity,
                            height: 55,

                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  openMap(lat, lng),

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF2563EB),

                                foregroundColor:
                                    Colors.white,

                                elevation: 0,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),

                              icon: const Icon(
                                Icons.map_outlined,
                              ),

                              label: const Text(
                                "Lihat Lokasi di Google Maps",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar:
          const BottomTabbar(currentIndex: 1),
    );
  }

  // ================================
  // INFO ROW
  // ================================
  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [

        Container(
          padding: const EdgeInsets.all(11),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF2563EB),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}