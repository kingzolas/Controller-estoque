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
  String? selectedStatus; // Variável para armazenar o status selecionado
  final ProductServices _productServices =
      ProductServices('ws://192.168.99.239:3000');

  @override
  void initState() {
    super.initState();
    selectedStatus = null; // Inicializa como null para exibir todos os produtos
    _loadData();
  }

  Future<void> _loadData() async {
    products = await _productServices.fetchProducts();
    filterProducts(); // Chama o filtro ao carregar os produtos
  }

  void filterProducts() {
    setState(() {
      // Se não houver filtros ativos, mostra todos os produtos
      if (searchName.isEmpty &&
          selectedCategory == null &&
          searchQuantity == null &&
          selectedStatus == null) {
        filteredProducts = List.from(products);
      } else {
        // Aplica os filtros caso haja algum critério selecionado
        filteredProducts = products.where((product) {
          final matchesName =
              product.name.toLowerCase().contains(searchName.toLowerCase());
          final matchesCategory =
              selectedCategory == null || product.category == selectedCategory;
          final matchesQuantity =
              searchQuantity == null || product.quantity == searchQuantity;

          bool matchesStatus = false;
          if (selectedStatus == 'novo') {
            matchesStatus = product.newQuantity > 0;
          } else if (selectedStatus == 'usado') {
            matchesStatus = product.usedQuantity > 0;
          } else if (selectedStatus == 'danificado') {
            matchesStatus = product.damagedQuantity > 0;
          } else {
            // Se o status não for selecionado, mostra todos os produtos
            matchesStatus = true;
          }

          return matchesName &&
              matchesCategory &&
              matchesQuantity &&
              matchesStatus;
        }).toList();
      }
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
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedStatus,
                    hint: Text('Status'),
                    items: [
                      DropdownMenuItem(
                          value: null, child: Text('Todos os Status')),
                      DropdownMenuItem(value: 'novo', child: Text('Novo')),
                      DropdownMenuItem(value: 'usado', child: Text('Usado')),
                      DropdownMenuItem(
                          value: 'danificado', child: Text('Danificado')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
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

                        // Define o card do produto de acordo com o status filtrado
                        Widget? productCard;
                        if (selectedStatus == 'novo' &&
                            product.newQuantity > 0) {
                          productCard = Cardproduct(
                            ontap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddProduct(
                                    produto: product,
                                  );
                                },
                              );
                            },
                            product: product,
                            status: 'novo',
                            quantity: product.newQuantity,
                            totalQuantity: product.newQuantity +
                                product.usedQuantity +
                                product.damagedQuantity,
                          );
                        } else if (selectedStatus == 'usado' &&
                            product.usedQuantity > 0) {
                          productCard = Cardproduct(
                            ontap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddProduct(
                                    produto: product,
                                  );
                                },
                              );
                            },
                            product: product,
                            status: 'usado',
                            quantity: product.usedQuantity,
                            totalQuantity: product.newQuantity +
                                product.usedQuantity +
                                product.damagedQuantity,
                          );
                        } else if (selectedStatus == 'danificado' &&
                            product.damagedQuantity > 0) {
                          productCard = Cardproduct(
                            ontap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddProduct(
                                    produto: product,
                                  );
                                },
                              );
                            },
                            product: product,
                            status: 'danificado',
                            quantity: product.damagedQuantity,
                            totalQuantity: product.newQuantity +
                                product.usedQuantity +
                                product.damagedQuantity,
                          );
                        } else if (selectedStatus == null) {
                          // Se nenhum status for selecionado, exibe todos os cards
                          productCard = Column(
                            children: [
                              if (product.newQuantity >= 0)
                                Cardproduct(
                                  ontap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AddProduct(
                                          produto: product,
                                        );
                                      },
                                    );
                                  },
                                  product: product,
                                  status: 'novo',
                                  quantity: product.newQuantity,
                                  totalQuantity: product.newQuantity +
                                      product.usedQuantity +
                                      product.damagedQuantity,
                                ),
                              if (product.usedQuantity >= 0)
                                Cardproduct(
                                  ontap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AddProduct(
                                          produto: product,
                                        );
                                      },
                                    );
                                  },
                                  product: product,
                                  status: 'usado',
                                  quantity: product.usedQuantity,
                                  totalQuantity: product.newQuantity +
                                      product.usedQuantity +
                                      product.damagedQuantity,
                                ),
                              if (product.damagedQuantity >= 0)
                                Cardproduct(
                                  ontap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AddProduct(
                                          produto: product,
                                        );
                                      },
                                    );
                                  },
                                  product: product,
                                  status: 'danificado',
                                  quantity: product.damagedQuantity,
                                  totalQuantity: product.newQuantity +
                                      product.usedQuantity +
                                      product.damagedQuantity,
                                ),
                            ],
                          );
                        }

                        return productCard ?? SizedBox.shrink();
                      },
                    ),
            ),
          ],
        ),
      ),
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
