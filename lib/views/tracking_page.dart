import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_silacak/widgets/bottom_tabbar.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  GoogleMapController? mapController;

  final String trackId = "device001";

  bool isMapReady = false;
  BitmapDescriptor? customMarker;

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
  }

  // ================================
  // LOAD CUSTOM MARKER
  // ================================
  Future<void> loadCustomMarker() async {
    try {
      final marker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(64, 64)),
        'assets/icons/motor.png',
      );

      if (mounted) {
        setState(() {
          customMarker = marker;
        });
      }
    } catch (e) {
      debugPrint("❌ Gagal load marker: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tracks')
            .doc(trackId)
            .collection('points')
            .orderBy('timestamp')
            .limit(100)
            .snapshots(),

        builder: (context, snapshot) {

          // ====================
          // LOADING
          // ====================
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ====================
          // ERROR
          // ====================
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // ====================
          // TRACK POINTS
          // ====================
          List<LatLng> trackPoints =
              docs.map((doc) {

            final data =
                doc.data() as Map<String, dynamic>;

            return LatLng(
              (data['lat'] ?? 0).toDouble(),
              (data['lng'] ?? 0).toDouble(),
            );

          }).where(
            (p) =>
                p.latitude != 0 &&
                p.longitude != 0,
          ).toList();

          // ====================
          // EMPTY
          // ====================
          if (trackPoints.isEmpty) {
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

          LatLng current = trackPoints.last;

          // ====================
          // AUTO FOLLOW
          // ====================
          if (mapController != null &&
              isMapReady) {

            WidgetsBinding.instance
                .addPostFrameCallback((_) {

              mapController!.animateCamera(
                CameraUpdate.newLatLng(current),
              );
            });
          }

          return Column(
            children: [

              // ====================
              // BLUE TOP CARD
              // ====================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(
                  24,
                  18,
                  24,
                  20,
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

                  child: Row(
                    children: [

                      // ICON
                      Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),

                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: const Icon(
                          Icons.motorcycle,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // TITLE
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(
                              "Tracking Aktif",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Device ID : $trackId",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // STATUS
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color:
                              Colors.green.withOpacity(0.2),

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
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ====================
              // MAP
              // ====================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    16,
                  ),

                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(30),

                    child: GoogleMap(
                      initialCameraPosition:
                          CameraPosition(
                        target: current,
                        zoom: 16,
                      ),

                      onMapCreated: (controller) {
                        mapController = controller;
                        isMapReady = true;
                      },

                      // ====================
                      // MARKER
                      // ====================
                      markers: {
                        Marker(
                          markerId:
                              const MarkerId("motor"),

                          position: current,

                          icon: customMarker ??
                              BitmapDescriptor
                                  .defaultMarker,

                          infoWindow:
                              const InfoWindow(
                            title:
                                "Posisi Kendaraan",
                          ),
                        )
                      },

                      // ====================
                      // POLYLINE
                      // ====================
                      polylines:
                          trackPoints.length >= 2
                              ? {

                                  // SHADOW
                                  Polyline(
                                    polylineId:
                                        const PolylineId(
                                            "shadow"),

                                    points:
                                        trackPoints,

                                    width: 8,

                                    color:
                                        Colors.black26,
                                  ),

                                  // MAIN
                                  Polyline(
                                    polylineId:
                                        const PolylineId(
                                            "main"),

                                    points:
                                        trackPoints,

                                    width: 5,

                                    color: const Color(
                                        0xFF2563EB),

                                    jointType:
                                        JointType.round,

                                    startCap:
                                        Cap.roundCap,

                                    endCap:
                                        Cap.roundCap,
                                  ),
                                }
                              : {},

                      myLocationEnabled: true,
                      myLocationButtonEnabled:
                          true,

                      zoomControlsEnabled: true,
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