class ModuleModel {
  final String id;
  final String plate;
  final String type;
  final String status;

  ModuleModel({
    required this.id,
    required this.plate,
    required this.type,
    required this.status,
  });

  // Konversi dari Map (misal dari Firestore atau API)
  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      id: map['id'] ?? '',
      plate: map['plate'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? '',
    );
  }

  // Konversi ke Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {'id': id, 'plate': plate, 'type': type, 'status': status};
  }
}
