import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_silacak/widgets/bottom_tabbar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: SafeArea(
        child: Column(
          children: [

// ================= HEADER =================
Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(
    20,
    14,
    20,
    16,
  ),

  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF0F172A),
        Color(0xFF2563EB),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),

    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
    ),
  ),

  child: Row(
    children: [

      Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius:
              BorderRadius.circular(16),
        ),

        child: const Icon(
          Icons.history_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),

      const SizedBox(width: 14),

      const Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              "Riwayat Kecelakaan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(height: 4),

            Text(
              "Data histori kecelakaan kendaraan",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      // ================= TOMBOL HAPUS =================
      GestureDetector(
        onTap: () async {

          final confirm =
              await showDialog(
            context: context,

            builder: (context) {
              return AlertDialog(
                title: const Text(
                  "Hapus Riwayat",
                ),

                content: const Text(
                  "Yakin ingin menghapus semua riwayat?",
                ),

                actions: [

                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },

                    child:
                        const Text("Batal"),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },

                    child:
                        const Text("Hapus"),
                  ),
                ],
              );
            },
          );

          if (confirm == true) {

            final snapshot =
                await FirebaseFirestore
                    .instance
                    .collection('history')
                    .where(
                      'userId',
                      isEqualTo:
                          user?.uid,
                    )
                    .get();

            for (var doc
                in snapshot.docs) {
              await doc.reference
                  .delete();
            }
          }
        },

        child: Container(
          padding:
              const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius:
                BorderRadius.circular(
                    18),
          ),

          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    ],
  ),
),
            // ================= HISTORY =================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('history')
                    .where(
                      'userId',
                      isEqualTo: user?.uid,
                    )
                    .orderBy(
                      'createdAt',
                      descending: true,
                    )
                    .snapshots(),

                builder: (context, snapshot) {

                  // LOADING
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // ERROR
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Error: ${snapshot.error}",
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  // EMPTY
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [

                          Icon(
                            Icons.history_toggle_off,
                            size: 90,
                            color: Colors.grey.shade400,
                          ),

                          const SizedBox(height: 14),

                          Text(
                            "Belum Ada Riwayat",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Data kecelakaan akan tampil di sini",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,

                    itemBuilder: (context, index) {

                      final data =
                          docs[index].data()
                              as Map<String, dynamic>;

                      final latitude =
                          (data['latitude'] ?? 0)
                              .toDouble();

                      final longitude =
                          (data['longitude'] ?? 0)
                              .toDouble();

                      final benturan =
                          (data['magnitude'] ?? 0)
                              .toDouble();

                      final status =
                          data['status'] ?? "recorded";

                      final eventTime =
                          data['eventTime'] ??
                              "Tidak ada waktu";

                      final bool gpsAktif =
                          latitude != 0 &&
                          longitude != 0;

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 18,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(26),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [

                            // ================= TOP =================
                            Container(
                              padding:
                                  const EdgeInsets.all(18),

                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF0F172A),
                                    Color(0xFF2563EB),
                                  ],
                                ),

                                borderRadius:
                                    BorderRadius.only(
                                  topLeft:
                                      Radius.circular(26),
                                  topRight:
                                      Radius.circular(26),
                                ),
                              ),

                              child: Row(
                                children: [

                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .all(12),

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors.white24,

                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  16),
                                    ),

                                    child: const Icon(
                                      Icons.warning_amber,
                                      color:
                                          Colors.white,
                                      size: 28,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [

                                        const Text(
                                          "Deteksi Kecelakaan",
                                          style:
                                              TextStyle(
                                            color: Colors
                                                .white,
                                            fontSize: 18,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 4),

                                        Text(
                                          eventTime,
                                          style:
                                              const TextStyle(
                                            color: Colors
                                                .white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors.redAccent,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  20),
                                    ),

                                    child: Text(
                                      status
                                          .toUpperCase(),
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ================= CONTENT =================
                            Padding(
                              padding:
                                  const EdgeInsets.all(
                                      18),

                              child: gpsAktif

                                  // ================= GPS AKTIF =================
                                  ? Column(
                                      children: [

                                        _buildInfoTile(
                                          Icons.speed_rounded,
                                          "Benturan",
                                          "${benturan.toStringAsFixed(2)} G",
                                        ),

                                        const SizedBox(
                                            height: 14),

                                        _buildInfoTile(
                                          Icons.location_on,
                                          "Latitude",
                                          latitude.toString(),
                                        ),

                                        const SizedBox(
                                            height: 14),

                                        _buildInfoTile(
                                          Icons.map,
                                          "Longitude",
                                          longitude.toString(),
                                        ),

                                        const SizedBox(
                                            height: 18),

                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      20),

                                          child: SizedBox(
                                            height: 230,

                                            child: GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target:
                                                    LatLng(
                                                  latitude,
                                                  longitude,
                                                ),
                                                zoom: 15,
                                              ),

                                              markers: {
                                                Marker(
                                                  markerId:
                                                      const MarkerId(
                                                          'lokasi'),

                                                  position:
                                                      LatLng(
                                                    latitude,
                                                    longitude,
                                                  ),
                                                ),
                                              },

                                              zoomControlsEnabled:
                                                  false,

                                              myLocationButtonEnabled:
                                                  false,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )

                                  // ================= GPS MATI =================
                                  : Column(
                                      children: [

                                        _buildInfoTile(
                                          Icons.speed_rounded,
                                          "Benturan",
                                          "${benturan.toStringAsFixed(2)} G",
                                        ),

                                        const SizedBox(
                                            height: 14),

                                        Container(
                                          width:
                                              double.infinity,

                                          padding:
                                              const EdgeInsets
                                                  .all(
                                                      18),

                                          decoration:
                                              BoxDecoration(
                                            color:
                                                const Color(
                                                    0xFFFFF7ED),

                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        18),
                                          ),

                                          child: const Row(
                                            children: [

                                              Icon(
                                                Icons
                                                    .gps_off,
                                                color: Colors
                                                    .orange,
                                                size: 30,
                                              ),

                                              SizedBox(
                                                  width:
                                                      12),

                                              Expanded(
                                                child:
                                                    Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,

                                                  children: [

                                                    Text(
                                                      "GPS Tidak Aktif",
                                                      style:
                                                          TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            15,
                                                      ),
                                                    ),

                                                    SizedBox(
                                                        height:
                                                            4),

                                                    Text(
                                                      "Lokasi kejadian tidak tersedia",
                                                      style:
                                                          TextStyle(
                                                        color:
                                                            Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          const BottomTabbar(currentIndex: 1),
    );
  }

  // ================= INFO TILE =================
  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: const Color(0x1A2563EB),
              borderRadius:
                  BorderRadius.circular(14),
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
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}