import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:velocityestoque/widgets/cardProduct.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../baseConect.dart';
import '../services/products_services.dart';
import '../websocket_service.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../widgets/add_product.dart';
import '../widgets/alert_dialog.dart';

class ProductListingPage extends StatefulWidget {
  @override
  _ProductListingPageState createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  String searchName = '';
  String? selectedCategory;
  int? searchQuantity;
  WebSocketService? _webSocketService;
  final ProductServices _productServices =
      ProductServices('ws://192.168.99.239:3000');

  @override
  void initState() {
    super.initState();
    // fetchProducts();

    _loadData();
    _initializeWebSocket();
  }

  Future<void> _loadData() async {
    products = await _productServices.fetchProducts();
    _applySortingAndFiltering(); // Chama a filtragem inicial
    _initializeWebSocket(); // Inicializa o WebSocket para manter dados em tempo real
    setState(() {});
  }

  void _initializeWebSocket() {
    _webSocketService = WebSocketService('ws://192.168.99.239:3000');
    _webSocketService!.channel.stream.listen((data) {
      final newProductJson = jsonDecode(data);
      print('Produto recebido: $newProductJson');
      if (newProductJson['event'] == 'productUpdated') {
        _updateProductList(newProductJson['data']);
      }
    });
  }

  void _updateProductList(dynamic updatedProductData) {
    final updatedProduct = Product.fromJson(updatedProductData);
    setState(() {
      int index = products.indexWhere((prod) => prod.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
      } else {
        products.add(updatedProduct);
      }
      _applySortingAndFiltering(); // Reaplica a filtragem e ordenação
    });
  }

  @override
  void dispose() {
    _webSocketService?.close();
    super.dispose();
  }

  // Future<void> fetchProducts() async {
  //   final url = Uri.parse('${Config.apiUrl}/api/products/');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final List<dynamic> productData = jsonDecode(response.body);
  //       setState(() {
  //         products = productData.map((json) => Product.fromJson(json)).toList();
  //         _applySortingAndFiltering();
  //       });
  //     } else {
  //       _showErrorDialog('Erro ao buscar produtos: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Erro: $e');
  //   }
  // }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _applySortingAndFiltering() {
    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    filterProducts();
  }

  void filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchesName =
            product.name.toLowerCase().contains(searchName.toLowerCase());
        final matchesCategory =
            selectedCategory == null || product.category == selectedCategory;
        final matchesQuantity =
            searchQuantity == null || product.quantity == searchQuantity;
        return matchesName && matchesCategory && matchesQuantity;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listagem de Produtos (${filteredProducts.length})',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Pesquisar por nome',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchName = value;
                        filterProducts();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        searchQuantity = int.tryParse(value);
                        filterProducts();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    hint: Text('Categoria'),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Todas as Categorias'),
                      ),
                      ...products
                          .map((product) => product.category)
                          .toSet()
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        filterProducts();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final totalQuantity = product.newQuantity +
                            product.usedQuantity +
                            product.damagedQuantity;

                        List<Widget> productCards = [];

                        // Condição para adicionar o card "Novo" se a quantidade for maior que zero
                        if (product.newQuantity > 0) {
                          productCards.add(
                            Cardproduct(
                              ontap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddProduct(
                                        produto: filteredProducts[index],
                                      );
                                    });
                              },
                              product: product,
                              status: 'novo',
                              quantity: product.newQuantity,
                              totalQuantity: totalQuantity,
                            ),
                          );
                        }

                        // Condição para adicionar o card "Usado" se a quantidade for maior que zero
                        if (product.usedQuantity > 0) {
                          productCards.add(
                            Cardproduct(
                              ontap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddProduct(
                                        produto: filteredProducts[index],
                                      );
                                    });
                              },
                              product: product,
                              status: 'usado',
                              quantity: product.usedQuantity,
                              totalQuantity: totalQuantity,
                            ),
                          );
                        }

                        // Condição para adicionar o card "Danificado" se a quantidade for maior que zero
                        if (product.damagedQuantity > 0) {
                          productCards.add(
                            Cardproduct(
                              ontap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddProduct(
                                        produto: filteredProducts[index],
                                      );
                                    });
                              },
                              product: product,
                              status: 'danificado',
                              quantity: product.damagedQuantity,
                              totalQuantity: totalQuantity,
                            ),
                          );
                        }

                        return Column(
                          children: productCards,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Ação para adicionar um novo produto
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Quantidade: ${product.quantity}'),
                Text('Categoria: ${product.category}'),
                Text('Descrição: ${product.description}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialogs(productModel: product);
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
