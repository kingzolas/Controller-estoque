import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;

  void setProducts(List<Product> products) {
    _products = products;
    _filteredProducts = List.from(products);
    notifyListeners();
  }

  void updateProductFromWebSocket(dynamic updateData) {
    // Processa a atualização de produto do WebSocket
    Product updatedProduct = Product.fromJson(updateData);
    final index =
        _products.indexWhere((product) => product.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      _filteredProducts =
          List.from(_products); // Atualiza os produtos filtrados
      notifyListeners();
    }
  }

  void filterProducts({
    String? searchName,
    String? selectedCategory,
    int? searchQuantity,
    String? selectedStatus,
  }) {
    _filteredProducts = _products.where((product) {
      final matchesName = searchName == null ||
          product.name.toLowerCase().contains(searchName.toLowerCase());
      final matchesCategory =
          selectedCategory == null || product.category == selectedCategory;
      final matchesQuantity =
          searchQuantity == null || product.quantity == searchQuantity;
      bool matchesStatus = true;
      if (selectedStatus != null) {
        if (selectedStatus == 'novo') {
          matchesStatus = product.newQuantity > 0;
        } else if (selectedStatus == 'usado') {
          matchesStatus = product.usedQuantity > 0;
        } else if (selectedStatus == 'danificado') {
          matchesStatus = product.damagedQuantity > 0;
        }
      }
      return matchesName && matchesCategory && matchesQuantity && matchesStatus;
    }).toList();

    notifyListeners();
  }
}
