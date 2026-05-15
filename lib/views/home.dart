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
        "latitude": (gps?["latitude"] as num?)?.toDouble(),
        "longitude": (gps?["longitude"] as num?)?.toDouble(),
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
      backgroundColor: const Color(0xFFF5F7FB),

      body: SafeArea(
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
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
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),

              child: Column(
                children: [

                  // ================= TOP =================
                  Row(
                    children: [

                      // PROFILE
                      Container(
                        padding: const EdgeInsets.all(4),

                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.2),

                          shape: BoxShape.circle,
                        ),

                        child: const CircleAvatar(
                          radius: 24,

                          backgroundColor:
                              Colors.white,

                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // USER INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(
                              "Smart Accident Monitoring",

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              userName,

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ================= STATS =================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),

                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.12),

                      borderRadius:
                          BorderRadius.circular(24),

                      border: Border.all(
                        color:
                            Colors.white.withOpacity(0.15),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,

                      children: [

                        _buildStat(
                          Icons.memory,
                          "$moduleCount",
                          "Modul",
                        ),

                        _divider(),

                        _buildStat(
                          Icons.location_on,
                          "${gpsList.length}",
                          "Lokasi",
                        ),

                        _divider(),

                        _buildStat(
                          Icons.shield,
                          "Aktif",
                          "Status",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: gpsList.isEmpty

                  ? const Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Icon(
                            Icons.location_off,
                            size: 70,
                            color: Colors.grey,
                          ),

                          SizedBox(height: 14),

                          Text(
                            "Belum ada data lokasi",

                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )

                  : ListView.builder(
                      padding: const EdgeInsets.all(20),

                      itemCount: gpsList.length,

                      itemBuilder: (context, index) {

                        final gps = gpsList[index];

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 20,
                          ),

                          child: LocationCard(
                            moduleId: gps["moduleId"],
                            latitude: gps["latitude"],
                            longitude: gps["longitude"],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          const BottomTabbar(currentIndex: 0),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 42,
      color: Colors.white24,
    );
  }

  Widget _buildStat(
    IconData icon,
    String value,
    String label,
  ) {

    return Column(
      children: [

        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),

        const SizedBox(height: 6),

        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,

          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
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

    final url = Uri.parse(
      "https://maps.google.com/?q=$latitude,$longitude",
    );

    launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),

            blurRadius: 15,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Card(
        elevation: 0,
        color: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(28),
        ),

        child: Padding(
          padding: const EdgeInsets.all(22),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ================= TOP =================
              Row(
                children: [

                  Container(
                    padding:
                        const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE0E7FF),

                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: const Icon(
                      Icons.location_on,
                      color:
                          Color(0xFF1D4ED8),
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
                          "Lokasi Kendaraan",

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Module ID : ${moduleId ?? '-'}",

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
                      color: latitude == null
                          ? Colors.red.shade50
                          : Colors.green.shade50,

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Text(
                      latitude == null
                          ? "OFFLINE"
                          : "ONLINE",

                      style: TextStyle(
                        color: latitude == null
                            ? Colors.red
                            : Colors.green,

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ================= LOCATION =================
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

                    _buildRow(
                      Icons.my_location,
                      "Latitude",
                      latitude?.toString() ??
                          "Tidak tersedia",
                    ),

                    const SizedBox(height: 16),

                    _buildRow(
                      Icons.place,
                      "Longitude",
                      longitude?.toString() ??
                          "Tidak tersedia",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton.icon(
                  onPressed: latitude == null
                      ? null
                      : openGoogleMaps,

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
                          BorderRadius.circular(
                              18),
                    ),
                  ),

                  icon: const Icon(
                    Icons.map_outlined,
                  ),

                  label: const Text(
                    "Lihat di Google Maps",

                    style: TextStyle(
                      fontSize: 16,
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
  }

  Widget _buildRow(
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

            borderRadius:
                BorderRadius.circular(14),
          ),

          child: Icon(
            icon,
            size: 20,
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
                  fontWeight:
                      FontWeight.w600,
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