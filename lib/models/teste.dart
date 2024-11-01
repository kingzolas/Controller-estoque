class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final int quantity;
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.quantity,
    required this.unit,
  });

  // Factory para converter JSON em Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json[
          '_id'], // Certifique-se de que o campo _id está sendo mapeado corretamente
      name: json['name'],
      description: json['description'],
      category: json['category'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }
}
