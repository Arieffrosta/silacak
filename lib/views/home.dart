import 'package:app_silacak/services/account_service.dart';
import 'package:app_silacak/services/module_service.dart';
import 'package:app_silacak/services/notification_service.dart';
import 'package:app_silacak/services/gps_service.dart';
import 'package:app_silacak/widgets/bottom_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Memuat...";
  int moduleCount = 0;

  List<Map<String, dynamic>> gpsList = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().initNotifications(context);
    });

    _loadUserData();
    _loadGPS();
  }

  // ============================
  // LOAD USER DATA
  // ============================
  Future<void> _loadUserData() async {
    final accountService = AccountService();
    final moduleService = ModuleService();

    final userData = await accountService.getUserData();
    final modules = await moduleService.getModulesByUser();

    if (!mounted) return;

    setState(() {
      userName =
          (userData?['name'] ?? "").trim().isEmpty
              ? "Pengguna Baru"
              : userData?['name'];

      moduleCount = modules.length;
    });
  }

  // ============================
  // LOAD GPS LIST
  // ============================
  Future<void> _loadGPS() async {
    final moduleService = ModuleService();
    final gpsService = GPSService();

    final modules = await moduleService.getModulesByUser();

    if (modules.isEmpty) return;

    List<Map<String, dynamic>> tempList = [];

    for (var m in modules) {
      final moduleId = m["id"];
      final gps = await gpsService.getGPSByModuleId(moduleId);

      tempList.add({
        "moduleId": moduleId,
        "latitude": gps?["latitude"],
        "longitude": gps?["longitude"],
      });
    }

    if (!mounted) return;

    setState(() {
      gpsList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ============================
      // HEADER USER
      // ============================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "$moduleCount Modul Terdaftar",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ============================
      // BODY
      // ============================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              gpsList.map((gps) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LocationCard(
                    moduleId: gps["moduleId"],
                    latitude: gps["latitude"],
                    longitude: gps["longitude"],
                  ),
                );
              }).toList(),
        ),
      ),

      bottomNavigationBar: const BottomTabbar(currentIndex: 0),
    );
  }
}

class LocationCard extends StatelessWidget {
  final String? moduleId;
  final double? latitude;
  final double? longitude;

  const LocationCard({
    super.key,
    required this.moduleId,
    required this.latitude,
    required this.longitude,
  });

  void openGoogleMaps() {
    if (latitude == null || longitude == null) return;

    final url = Uri.parse("https://maps.google.com/?q=$latitude,$longitude");
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "📍 Lokasi Kendaraan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            // Module ID
            Text(
              "Module ID: ${moduleId ?? "-"}",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),

            const SizedBox(height: 6),

            // Coordinates
            Text(
              latitude == null
                  ? "Tidak ada data lokasi"
                  : "Lat: $latitude\nLon: $longitude",
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 14),

            // Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: latitude == null ? null : openGoogleMaps,
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text(
                  "Lihat di Google Maps",
                  style: TextStyle(color: Colors.white),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
