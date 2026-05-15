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
        modules =
            data.map((d) => ModuleModel.fromMap(d)).toList();
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
      backgroundColor: const Color(0xFFF1F5F9),

      body: Column(
        children: [

          // =========================
          // HEADER
          // =========================
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
                      color:
                          Colors.white.withOpacity(0.15),

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: const Icon(
                      Icons.memory_rounded,
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
                          "Modul Terdaftar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "${modules.length} Modul Terhubung",
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
                          "AKTIF",
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

          // =========================
          // CONTENT
          // =========================
          Expanded(
            child:
                isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )

                    : modules.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            Icon(
                              Icons.memory_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),

                            SizedBox(height: 14),

                            Text(
                              "Belum ada modul terdaftar",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )

                    : RefreshIndicator(
                        onRefresh: _loadModules,

                        child: ListView.builder(
                          padding:
                              const EdgeInsets.all(16),

                          itemCount: modules.length,

                          itemBuilder: (
                            context,
                            index,
                          ) {

                            final e = modules[index];

                            final isActive =
                                e.status == "Aktif";

                            return Container(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 18,
                              ),

                              decoration: BoxDecoration(
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

                              child: Card(
                                elevation: 0,
                                color: Colors.white,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              28),
                                ),

                                child: InkWell(
                                  borderRadius:
                                      BorderRadius
                                          .circular(28),

                                  onTap: () =>
                                      _showDetailModule(
                                    context,
                                    e,
                                  ),

                                  child: Padding(
                                    padding:
                                        const EdgeInsets
                                            .all(22),

                                    child: Row(
                                      children: [

                                        // ICON
                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .all(
                                                  16),

                                          decoration:
                                              BoxDecoration(
                                            color:
                                                isActive
                                                    ? Colors
                                                        .green
                                                        .shade50
                                                    : Colors
                                                        .red
                                                        .shade50,

                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                          ),

                                          child: Icon(
                                            Icons
                                                .motorcycle,

                                            color:
                                                isActive
                                                    ? Colors
                                                        .green
                                                    : Colors
                                                        .red,

                                            size: 32,
                                          ),
                                        ),

                                        const SizedBox(
                                            width: 16),

                                        // INFO
                                        Expanded(
                                          child:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,

                                            children: [

                                              Text(
                                                e.plate,

                                                style:
                                                    const TextStyle(
                                                  fontSize:
                                                      18,

                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(
                                                  height:
                                                      4),

                                              Text(
                                                "${e.type} • Modul: ${e.id}",

                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.grey,

                                                  fontSize:
                                                      13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // STATUS
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal:
                                                14,
                                            vertical:
                                                8,
                                          ),

                                          decoration:
                                              BoxDecoration(
                                            color:
                                                isActive
                                                    ? Colors
                                                        .green
                                                        .shade50
                                                    : Colors
                                                        .red
                                                        .shade50,

                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                          ),

                                          child: Text(
                                            e.status,

                                            style:
                                                TextStyle(
                                              color:
                                                  isActive
                                                      ? Colors.green
                                                      : Colors.red,

                                              fontWeight:
                                                  FontWeight.bold,

                                              fontSize:
                                                  12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      // =========================
      // FAB
      // =========================
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () =>
            _showAddModuleForm(context),

        icon: const Icon(Icons.add),

        label: const Text(
          "Tambah Modul",
        ),

        backgroundColor:
            const Color(0xFF2563EB),

        foregroundColor: Colors.white,

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20),
        ),
      ),

      bottomNavigationBar:
          const BottomTabbar(currentIndex: 3),
    );
  }

  // =========================
  // FORM TAMBAH MODUL
  // =========================
  void _showAddModuleForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final TextEditingController idController =
        TextEditingController();

    final TextEditingController plateController =
        TextEditingController();

    final TextEditingController typeController =
        TextEditingController();

    String status = "Aktif";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),

      builder: (context) {

        return SafeArea(
          child: Padding(
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
                mainAxisSize: MainAxisSize.min,

                children: [

                  Container(
                    width: 60,
                    height: 6,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,

                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Tambah Modul Baru",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _modernField(
                    controller: idController,
                    label: "ID Modul",
                    icon: Icons.memory,
                  ),

                  const SizedBox(height: 16),

                  _modernField(
                    controller: plateController,
                    label: "Plat Nomor",
                    icon: Icons.pin,
                  ),

                  const SizedBox(height: 16),

                  _modernField(
                    controller: typeController,
                    label: "Jenis Kendaraan",
                    icon:
                        Icons.directions_car,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: status,

                    decoration:
                        _dropdownDecoration(
                      "Status Modul",
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: "Aktif",
                        child: Text("Aktif"),
                      ),
                      DropdownMenuItem(
                        value: "Offline",
                        child: Text("Offline"),
                      ),
                    ],

                    onChanged: (value) =>
                        status = value!,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,

                    child: ElevatedButton(
                      onPressed: () async {

                        final newModule =
                            ModuleModel(
                          id:
                              idController.text,

                          plate:
                              plateController.text,

                          type:
                              typeController.text,

                          status: status,
                        );

                        await _moduleService
                            .addModule(newModule);

                        Navigator.pop(context);

                        SuccessDialog.show(
                          context,
                          message:
                              'Modul berhasil ditambahkan!',
                        );

                        _loadModules();
                      },

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

                      child: const Text(
                        "Simpan",
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
      },
    );
  }

  // =========================
  // DETAIL MODUL
  // =========================
  void _showDetailModule(
    BuildContext context,
    ModuleModel module,
  ) {}

  // =========================
  // MODERN FIELD
  // =========================
  Widget _modernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        filled: true,
        fillColor: const Color(0xFFF8FAFC),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // =========================
  // DROPDOWN DECORATION
  // =========================
  InputDecoration _dropdownDecoration(
    String label,
  ) {
    return InputDecoration(
      labelText: label,

      filled: true,
      fillColor: const Color(0xFFF8FAFC),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),

        borderSide: BorderSide.none,
      ),
    );
  }
}