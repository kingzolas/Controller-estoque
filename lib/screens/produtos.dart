import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:velocityestoque/dashboard.dart';
import 'package:velocityestoque/widgets/cardProduct.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../baseConect.dart';
import '../services/products_services.dart';
import '../websocket_service.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../widgets/add_product.dart';
import '../widgets/alert_dialog.dart';
import '../widgets/edit_product.dart';

class ProductListingPage extends StatefulWidget {
  @override
  _ProductListingPageState createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  String searchName = '';
  String? selectedCategory = null;
  int? searchQuantity;
  String? selectedStatus; // Variável para armazenar o status selecionado
  final ProductServices _productServices =
      ProductServices('ws://${Socket.apiUrl}');
  List<Map<String, dynamic>> _categories = []; // Mapeia categorias
  bool isLoading = true;
  bool hasActiveFilters = false;

  void clearFilters() {
    setState(() {
      selectedCategory = null;
      searchName = '';
      selectedStatus = null;
      hasActiveFilters = false;
      filteredProducts = List.from(products);
    });
  }

  @override
  void initState() {
    super.initState();
    selectedStatus = null; // Inicializa como null para exibir todos os produtos
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Carregar categorias
      _categories = await _productServices.fetchCategories();
      print('Categorias carregadas: $_categories');

      // Carregar produtos
      products = await _productServices.fetchProducts();
      print('Produtos carregados: ${products.length}');

      // Iniciar escuta para atualizações
      _startListeningForUpdates();

      // Filtrar produtos (se aplicável)
      filterProducts();
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para começar a escutar as atualizações via WebSocket
  void _startListeningForUpdates() {
    _productServices.listenForProductUpdates((Product updatedProduct) {
      setState(() {
        // Verifica se o produto já existe na lista
        int index =
            products.indexWhere((product) => product.id == updatedProduct.id);

        if (index != -1) {
          // Atualiza o produto existente
          products[index] = updatedProduct;
        } else {
          // Adiciona o novo produto à lista
          products.add(updatedProduct);
        }

        // Atualiza a lista filtrada após cada mudança
        filterProducts();
      });
    });
  }

  void filterProducts() {
    setState(() {
      hasActiveFilters = selectedCategory != null ||
          selectedStatus != null ||
          searchName != '';

      // Se não houver filtros ativos, mostra todos os produtos
      if (!hasActiveFilters) {
        filteredProducts = List.from(products);
      } else {
        // Aplica os filtros caso haja algum critério selecionado
        print(selectedCategory);
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
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Estoque de Itens',
                        style: TextStyle(
                          color: Color(0xFF01244E),
                          fontSize: 40.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                      // Text(
                      //   'Listagem de Produtos (${filteredProducts.length})',
                      //   style: TextStyle(
                      //       fontSize: 24.sp, fontWeight: FontWeight.bold),
                      // ),
                    ],
                  ),
                  SizedBox(height: 0.sp),
                  Text(
                    'Abaixo estão todos os itens em estoque',
                    style: TextStyle(
                      color: Color(0xFFADBFD4),
                      fontSize: 25.sp,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          // color: Colors.red,
                          child: Row(
                            children: [
                              Container(
                                width: 570.sp,
                                height: 50.sp,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFE3E8EE),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                    Icon(
                                      PhosphorIcons.magnifying_glass_bold,
                                      color: Color(0xff8092A8),
                                    ),
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                    Container(
                                      // color: Colors.red,
                                      width: 500.sp,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Pesquisar por nome',
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            searchName = value;
                                            filterProducts();
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 10.sp),
                              SizedBox(width: 10.sp),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    'Filtrar categoria',
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  items: _categories
                                      .map((category) =>
                                          DropdownMenuItem<String>(
                                            value: category['name'].toString(),
                                            child: Text(
                                              category['name'],
                                              style: TextStyle(
                                                fontSize: 23.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedCategory,
                                  onChanged: (value) {
                                    if (value != selectedCategory) {
                                      // Verifica se o valor foi alterado
                                      print("categoria selecionada $value");
                                      setState(() {
                                        selectedCategory = value as String?;
                                      });
                                      filterProducts(); // Chama a função de filtro após a mudança
                                    }
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 50.sp,
                                    width: 240.sp,
                                    decoration: BoxDecoration(
                                      color: Color(0xff01244E),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.sp),
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                    ),
                                    iconSize: 24.sp,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200.sp,
                                    width: 400,
                                    decoration: BoxDecoration(
                                      color: Color(0xff01244E),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 48.sp,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.sp),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.sp),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    selectedStatus ?? 'Todos os Status',
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.adjust,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 10.sp,
                                          ),
                                          Text(
                                            'Todos os Status',
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                        value: 'novo',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.adjust,
                                              color: Colors.green,
                                            ),
                                            SizedBox(
                                              width: 10.sp,
                                            ),
                                            Text(
                                              'Novo',
                                              style: TextStyle(
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )),
                                    DropdownMenuItem(
                                        value: 'usado',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.adjust,
                                              color: Color(0xffFEB100),
                                            ),
                                            SizedBox(
                                              width: 10.sp,
                                            ),
                                            Text(
                                              'Usado',
                                              style: TextStyle(
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )),
                                    DropdownMenuItem(
                                        value: 'danificado',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.adjust,
                                              color: Color(0xffF25252),
                                            ),
                                            SizedBox(
                                              width: 10.sp,
                                            ),
                                            Text(
                                              'Danificado',
                                              style: TextStyle(
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                  value:
                                      selectedStatus, // Alterado para selectedStatus
                                  onChanged: (value) {
                                    setState(() {
                                      selectedStatus = value as String?;
                                    });
                                    filterProducts();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 50.sp,
                                    width: 220.sp,
                                    decoration: BoxDecoration(
                                      color: Color(0xff01244E),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.sp),
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                    ),
                                    iconSize: 24.sp,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200.sp,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Color(0xff01244E),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 48.sp,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.sp),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                        if (hasActiveFilters)
                          InkWell(
                            onTap: clearFilters, // Limpa os filtros ao clicar
                            child: Container(
                              height: 50,
                              width: 220,
                              decoration: BoxDecoration(
                                color: Color(0xffFEB100),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  Text(
                                    'Remover filtros',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 23,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: Lottie.asset(
                                "lib/assets/loading_animation.json",
                                height: 300.sp,
                                width: 300.sp),
                          )
                        : filteredProducts.isEmpty
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
                                      edit: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return EditProduct(
                                              produto: product,
                                            );
                                          },
                                        );
                                      },
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
                                      edit: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return EditProduct(
                                              produto: product,
                                            );
                                          },
                                        );
                                      },
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
                                      edit: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return EditProduct(
                                              produto: product,
                                            );
                                          },
                                        );
                                      },
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
                                            edit: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return EditProduct(
                                                    produto: product,
                                                  );
                                                },
                                              );
                                            },
                                            ontap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
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
                                            edit: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return EditProduct(
                                                    produto: product,
                                                  );
                                                },
                                              );
                                            },
                                            ontap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
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
                                            edit: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return EditProduct(
                                                    produto: product,
                                                  );
                                                },
                                              );
                                            },
                                            ontap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
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
        });
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
