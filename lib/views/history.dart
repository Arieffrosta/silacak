import 'package:app_silacak/widgets/bottom_tabbar.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy riwayat kecelakaan
    final accidents = [
      {"time": "12/11/2025 14:05", "location": "Cibinong", "impact": "8.6 G"},
      {"time": "10/11/2025 17:42", "location": "Depok", "impact": "6.3 G"},
      {
        "time": "08/11/2025 09:20",
        "location": "Bogor Utara",
        "impact": "7.1 G",
      },
      {"time": "05/11/2025 22:18", "location": "Citeureup", "impact": "5.8 G"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Riwayat Kecelakaan'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: accidents.length,
        itemBuilder: (context, index) {
          final e = accidents[index];
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: Text(e["location"]!),
              subtitle: Text("Waktu: ${e["time"]!}"),
              trailing: Text(
                e["impact"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Aksi ke Google Maps
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomTabbar(currentIndex: 1),
    );
  }
}
