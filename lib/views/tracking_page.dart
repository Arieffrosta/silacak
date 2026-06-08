import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_silacak/widgets/bottom_tabbar.dart';
import 'dart:math';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  GoogleMapController? mapController;

  final String trackId = "device001";

  bool isMapReady = false;

  LatLng? lastCameraPosition;

  String? selectedDate;

  double calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double R = 6371000;

  final dLat =
      (lat2 - lat1) * pi / 180;

  final dLon =
      (lon2 - lon1) * pi / 180;

  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);

  final c =
      2 * atan2(
        sqrt(a),
        sqrt(1 - a),
      );

  return R * c;
}

  Future<void> loadLatestDate() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('tracks')
      .doc(trackId)
      .collection('sessions')
      .get();

        if (!mounted) return;

  if (snapshot.docs.isNotEmpty) {
    final dates =
        snapshot.docs.map((e) => e.id).toList();

    dates.sort(
      (a, b) => b.compareTo(a),
    );

    setState(() {
      selectedDate = dates.first;
    });
  }
}

@override
void initState() {
  super.initState();
  loadLatestDate();
}


  @override
  Widget build(BuildContext context) {

  if (selectedDate == null) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
    .collection('tracks')
    .doc(trackId)
    .collection('sessions')
    .doc(selectedDate!)
    .collection('points')
    .orderBy('timestamp')
    .snapshots(),

        builder: (context, snapshot) {

          // ================================
          // LOADING
          // ================================
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ================================
          // ERROR
          // ================================
          if (snapshot.hasError) {

            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // ================================
          // EMPTY
          // ================================
          if (docs.isEmpty) {

            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.gps_off_rounded,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 14),

                  Text(
                    "Belum ada data GPS",

                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // ================================
          // TRACK POINTS
          // ================================
          LatLng? lastPoint;

List<LatLng> trackPoints = [];

for (var doc in docs) {

  try {

    final data =
        doc.data() as Map<String, dynamic>;

    final lat =
        (data['lat'] ?? 0).toDouble();

    final lng =
        (data['lng'] ?? 0).toDouble();

    if (lat == 0 || lng == 0) {
      continue;
    }

    final currentPoint =
        LatLng(lat, lng);

    if (lastPoint == null) {

      trackPoints.add(
        currentPoint,
      );

      lastPoint = currentPoint;

      continue;
    }

    final distance =
        calculateDistance(
      lastPoint!.latitude,
      lastPoint!.longitude,
      currentPoint.latitude,
      currentPoint.longitude,
    );

    // titik terlalu dekat
    if (distance < 15) {
      continue;
    }

    // titik loncat jauh
    if (distance > 500) {
      continue;
    }

    trackPoints.add(
      currentPoint,
    );

    lastPoint = currentPoint;

  } catch (_) {}
}

List<LatLng> displayPoints = [];

LatLng? lastDisplayed;

for (final point in trackPoints) {

  if (lastDisplayed == null) {

    displayPoints.add(point);
    lastDisplayed = point;

    continue;
  }

  final distance =
      calculateDistance(
    lastDisplayed.latitude,
    lastDisplayed.longitude,
    point.latitude,
    point.longitude,
  );

  // tampilkan hanya jika beda > 20 meter
  if (distance >= 20) {

    displayPoints.add(point);
    lastDisplayed = point;
  }
}

          // ================================
          // EMPTY VALID POINTS
          // ================================
          if (displayPoints.isEmpty) {

            return const Center(
              child: Text(
                "Data lokasi tidak valid",
              ),
            );
          }

          final LatLng current =
              displayPoints.last;

          // ================================
          // AUTO FOLLOW (ANTI CRASH)
          // ================================
          if (mapController != null &&
              isMapReady) {

            if (lastCameraPosition == null ||
                lastCameraPosition != current) {

              lastCameraPosition = current;

              Future.delayed(
                const Duration(milliseconds: 500),
                () {

                  try {

                    mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: current,
                          zoom: 16,
                        ),
                      ),
                    );

                  } catch (_) {}
                },
              );
            }
          }

return Column(
  children: [

    // ================= HEADER =================
    Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        6,
        20,
        12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.motorcycle,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Tracking Aktif",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    "Device ID : $trackId",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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
                color:
                    Colors.green.withOpacity(0.18),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.greenAccent,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "LIVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),

    // ================= CARD INFO =================
    Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tracks')
                .doc(trackId)
                .collection('sessions')
                .snapshots(),
            builder: (context, snap) {

              if (!snap.hasData) {
                return const SizedBox();
              }

              final dates = snap.data!.docs
                  .map((e) => e.id)
                  .toList();
                  dates.sort((a, b) => b.compareTo(a));

              if (dates.isEmpty) {
                return const SizedBox();
              }

              return DropdownButtonFormField<
                  String>(
                value: dates.contains(selectedDate)
    ? selectedDate
    : dates.first,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Riwayat Tracking",
                  border:
                      OutlineInputBorder(),
                ),
                items: dates
                    .map(
                      (date) =>
                          DropdownMenuItem(
                        value: date,
                        child: Text(date),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedDate = value;
                  });
                },
              );
            },
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              const Icon(
                Icons.route,
                color: Colors.blue,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  "${displayPoints.length} titik ditampilkan dari ${docs.length} data GPS",
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                ),
                onPressed: () async {

                  final points =
                      await FirebaseFirestore
                          .instance
                          .collection(
                              'tracks')
                          .doc(trackId)
                          .collection(
                              'sessions')
                          .doc(selectedDate!)
                          .collection(
                              'points')
                          .get();

                  final batch =
                      FirebaseFirestore
                          .instance
                          .batch();

                  for (var doc
                      in points.docs) {
                    batch.delete(
                        doc.reference);
                  }

                  await batch.commit();

                  if (mounted) {
                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Riwayat berhasil dihapus",
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                label: const Text(
                  "Hapus",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),

    // ================= MAP =================
    Expanded(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          14,
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(26),
          child: GoogleMap(
            initialCameraPosition:
                CameraPosition(
              target: current,
              zoom: 16,
            ),

            onMapCreated:
                (controller) {
              mapController =
                  controller;
              isMapReady = true;
            },

            markers: {
              Marker(
                markerId:
                    const MarkerId(
                        "motor"),
                position: current,
                infoWindow:
                    const InfoWindow(
                  title:
                      "Posisi Kendaraan",
                ),
              ),
            },

            polylines:
                displayPoints.length >= 2 
                    ? {
                        Polyline(
                          polylineId:
                              const PolylineId(
                                  "main"),
                          points:
                              displayPoints,
                          width: 5,
                          color:
                              const Color(
                            0xFF2563EB,
                          ),
                        ),
                      }
                    : {},

            zoomControlsEnabled:
                true,
            compassEnabled: true,
          ),
        ),
      ),
    ),
  ],
);
        },
      ),
      bottomNavigationBar:
          const BottomTabbar(currentIndex: 2),
    );
  }
}