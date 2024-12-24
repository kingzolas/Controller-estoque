class MarcasModel {
  final String name;
  final String fabricante;
  final String id;

  MarcasModel({
    required this.name,
    required this.fabricante,
    required this.id,
  });

  factory MarcasModel.fromJson(Map<String, dynamic> json) {
    return MarcasModel(
      name: json['name'] != null ? json['name'] as String : "Desconhecido",
      fabricante: json['fabricante'] != null
          ? json['fabricante'] as String
          : "Desconhecido",
      id: json['_id'] as String, // Certifique-se de usar '_id' aqui.
    );
  }
}
