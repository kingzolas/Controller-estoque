class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final int quantity;
  final String unit;
  final DateTime createdAt;
  final String status;
  final String marca;
  final int newQuantity;
  final int usedQuantity;
  final int damagedQuantity;
  final int totalQuantity;

  Product({
    required this.marca,
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    required this.status,
    required this.newQuantity,
    required this.usedQuantity,
    required this.damagedQuantity,
    required this.totalQuantity,
  });

  // Factory para converter JSON em Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      marca: json['marca']?['name'] ?? 'Sem marca',
      status: json['status'] ?? '',
      id: json['_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      name: json['name'] ?? 'Nome Desconhecido',
      description: json['description'] ?? 'Sem Descrição',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'Unidade Desconhecida',
      category: (json['category'] is Map && json['category']['name'] != null)
          ? json['category']['name']
          : 'Sem Categoria',
      newQuantity: json['conditionQuantities']?['new'] ?? 0,
      usedQuantity: json['conditionQuantities']?['used'] ?? 0,
      damagedQuantity: json['conditionQuantities']?['damaged'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }
}
