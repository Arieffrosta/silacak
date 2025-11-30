import 'package:flutter/material.dart';
import 'package:app_silacak/models/module_model.dart';
import 'package:app_silacak/services/module_service.dart';
import 'package:app_silacak/widgets/bottom_tabbar.dart';
import 'package:app_silacak/widgets/success_dialog.dart';

class ModulePage extends StatefulWidget {
  const ModulePage({super.key});

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  final ModuleService _moduleService = ModuleService();
  List<ModuleModel> modules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() => isLoading = true);
    try {
      final data = await _moduleService.getModulesByUser();
      setState(() {
        modules = data.map((d) => ModuleModel.fromMap(d)).toList();
      });
    } catch (e) {
      debugPrint("❌ Gagal memuat modul: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Modul Terdaftar"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : modules.isEmpty
              ? const Center(child: Text("Belum ada modul terdaftar"))
              : RefreshIndicator(
                onRefresh: _loadModules,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final e = modules[index];
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.directions_car,
                          color:
                              e.status == "Aktif" ? Colors.green : Colors.red,
                        ),
                        title: Text(e.plate),
                        subtitle: Text("${e.type} • Modul: ${e.id}"),
                        trailing: Text(
                          e.status,
                          style: TextStyle(
                            color:
                                e.status == "Aktif" ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _showDetailModule(context, e),
                      ),
                    );
                  },
                ),
              ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModuleForm(context),
        icon: const Icon(Icons.add),
        label: const Text("Tambah Modul"),
        backgroundColor: Colors.blue,
      ),

      bottomNavigationBar: const BottomTabbar(currentIndex: 2),
    );
  }

  // 🔹 Tambah Modul
  void _showAddModuleForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController idController = TextEditingController();
    final TextEditingController plateController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    String status = "Aktif";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const Text(
                      "Tambah Modul Baru",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: "ID Modul",
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? "ID Modul tidak boleh kosong"
                                  : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: plateController,
                      decoration: const InputDecoration(
                        labelText: "Plat Nomor",
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty ? "Plat Nomor wajib diisi" : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: "Jenis Kendaraan",
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? "Jenis kendaraan wajib diisi"
                                  : null,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: "Status Modul",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                        DropdownMenuItem(
                          value: "Offline",
                          child: Text("Offline"),
                        ),
                      ],
                      onChanged: (value) => status = value!,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final newModule = ModuleModel(
                            id: idController.text,
                            plate: plateController.text,
                            type: typeController.text,
                            status: status,
                          );

                          await _moduleService.addModule(newModule);
                          Navigator.pop(context);
                          SuccessDialog.show(
                            context,
                            message: 'Modul berhasil ditambahkan!',
                          );
                          _loadModules();
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text("Simpan"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔹 Detail & Edit Modul
  void _showDetailModule(BuildContext context, ModuleModel module) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController idController = TextEditingController(
      text: module.id,
    );
    final TextEditingController plateController = TextEditingController(
      text: module.plate,
    );
    final TextEditingController typeController = TextEditingController(
      text: module.type,
    );
    String status = module.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const Text(
                      "Detail Modul",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: idController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "ID Modul",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: plateController,
                      decoration: const InputDecoration(
                        labelText: "Plat Nomor",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: "Jenis Kendaraan",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: "Status Modul",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                        DropdownMenuItem(
                          value: "Offline",
                          child: Text("Offline"),
                        ),
                      ],
                      onChanged: (value) => status = value!,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final updatedModule = ModuleModel(
                                id: idController.text,
                                plate: plateController.text,
                                type: typeController.text,
                                status: status,
                              );
                              await _moduleService.updateModule(updatedModule);
                              Navigator.pop(context);
                              SuccessDialog.show(
                                context,
                                message: 'Data modul berhasil diperbarui!',
                              );
                              _loadModules();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text("Simpan"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await _moduleService.deleteModule(module.id);
                              Navigator.pop(context);
                              SuccessDialog.show(
                                context,
                                message: 'Modul berhasil dihapus!',
                              );
                              _loadModules();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text("Hapus"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
