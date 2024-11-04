import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocityestoque/models/member_model.dart';
import 'package:velocityestoque/models/product_model.dart';
import 'package:velocityestoque/widgets/add_product.dart';
import 'package:velocityestoque/widgets/cardProduct2.dart';
import '../services/products_services.dart';

class AddMemberProducts extends StatefulWidget {
  final MemberModel membro;
  const AddMemberProducts({super.key, required this.membro});

  @override
  State<AddMemberProducts> createState() => _AddMemberProductsState();
}

class _AddMemberProductsState extends State<AddMemberProducts> {
  List<Map<String, dynamic>> _categories = [];
  String? selectedCategory;
  List<Product> products = [];
  List<Product> filteredProducts = [];
  String searchName = '';
  final ProductServices _productServices =
      ProductServices('ws://192.168.99.239:3000');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    products = await _productServices.fetchProducts();
    _applySortingAndFiltering(); // Filtragem inicial
    setState(() {});
  }

  void filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchesName =
            product.name.toLowerCase().contains(searchName.toLowerCase());
        final matchesCategory =
            selectedCategory == null || product.category == selectedCategory;
        return matchesName && matchesCategory;
      }).toList();
    });
  }

  void _applySortingAndFiltering() {
    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AlertDialog(
          content: Container(
            height: 795.sp,
            width: 1600.sp,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: 25.sp),
                  _buildSearchAndFilter(),
                  SizedBox(height: 15.sp),
                  _buildProductList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estoque de Itens',
              style: TextStyle(
                  color: Color(0xFF01244E),
                  fontWeight: FontWeight.w700,
                  fontSize: 40.sp),
            ),
            Text(
              'Abaixo estão todos os itens em estoque, adicione o item que deseja ao histórico de retirada do usuário.',
              style: TextStyle(
                  color: Color(0xffADBFD4),
                  fontWeight: FontWeight.w500,
                  fontSize: 25.sp),
            ),
          ],
        ),
        _containerAction(
          ontap: () {},
          color: Color(0xff4CC67A),
          icon: Icons.bookmark_added,
          text: 'Finalizar',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Flex(
      direction: Axis.horizontal,
      children: [
        _buildSearchField(),
        SizedBox(width: 20.sp),
        _buildCategoryDropdown(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 50.sp,
      width: 570.sp,
      decoration: BoxDecoration(
        color: Color(0xffE3E8EE),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Color(0xff8092A8)),
          hintText: "Encontra item pelo nome",
          hintStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 24.sp,
              color: Color(0xffADBFD4)),
          fillColor: Color(0xffE3E8EE),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          searchName = value;
          filterProducts();
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        hint: Text(
          'Filtrar categoria',
          style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category['id'].toString(),
            child: Text(
              category['name'],
              style: TextStyle(
                  fontSize: 23.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        value: selectedCategory,
        onChanged: (value) {
          setState(() {
            selectedCategory = value as String?;
          });
          filterProducts();
        },
        buttonStyleData: ButtonStyleData(
          height: 50.sp,
          width: 240.sp,
          decoration: BoxDecoration(
              color: Color(0xff01244E),
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          iconSize: 24.sp,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200.sp,
          width: 400,
          decoration: BoxDecoration(
              color: Color(0xff01244E),
              borderRadius: BorderRadius.circular(10)),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 48.sp,
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0F3F7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: filteredProducts.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return _buildProductCards(product);
                },
              ),
      ),
    );
  }

  Widget _buildProductCards(Product product) {
    final totalQuantity =
        product.newQuantity + product.usedQuantity + product.damagedQuantity;

    List<Widget> productCards = [];

    if (product.newQuantity > 0) {
      productCards
          .add(_buildCard(product, 'novo', product.newQuantity, totalQuantity));
    }
    if (product.usedQuantity > 0) {
      productCards.add(
          _buildCard(product, 'usado', product.usedQuantity, totalQuantity));
    }
    if (product.damagedQuantity > 0) {
      productCards.add(_buildCard(
          product, 'danificado', product.damagedQuantity, totalQuantity));
    }

    return Column(children: productCards);
  }

  Widget _buildCard(
      Product product, String status, int quantity, int totalQuantity) {
    final TextEditingController _controller =
        TextEditingController(); // Controlador para o campo de entrada

    return CardProduct2(
      ontap: () {
        // Aqui você pode fazer o que desejar com o valor do campo de texto
        String inputQuantity = _controller.text; // Pega o valor do campo
        // Exemplo: apenas exibir o valor em um print
        print('Quantidade retirada: $inputQuantity');

        // Você pode adicionar mais lógica aqui, como validação ou armazenamento
      },
      child: Container(
        width: 300.sp,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Quant. Retirada ',
              style: TextStyle(
                color: Color(0xFF889BB2),
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
            Container(
              width: 110.sp,
              height: 60.sp,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
                ),
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      product: product,
      status: status,
      quantity: quantity,
      totalQuantity: totalQuantity,
    );
  }
}

Widget _containerAction({
  required String text,
  required IconData icon,
  required Color color,
  required VoidCallback ontap,
}) {
  return InkWell(
    onTap: ontap,
    child: Container(
      height: 50.sp,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 24.sp),
          ),
        ),
      ),
    ),
  );
}
