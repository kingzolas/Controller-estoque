import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:popover/popover.dart';
import 'package:velocityestoque/models/marcas_model.dart';
import 'package:velocityestoque/provider/productController.dart';
import 'package:velocityestoque/screens/historic_products.dart';
import 'package:velocityestoque/services/products_services.dart';
import 'package:velocityestoque/widgets/add_member_products.dart';
import 'package:velocityestoque/widgets/return_itens_member.dart';

import '../models/member_model.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

import '../models/movimentacao_model.dart';
import '../models/product_model.dart';

class AlertDialogProduct extends StatefulWidget {
  final MemberModel membro;
  const AlertDialogProduct({super.key, required this.membro});

  @override
  State<AlertDialogProduct> createState() => _AlertDialogProductState();
}

class _AlertDialogProductState extends State<AlertDialogProduct> {
  List<Map<String, dynamic>> _categories = []; // Mapeia categorias
  final ProductServices _productServices =
      ProductServices('ws://192.168.99.239:3000');
  String? selectedCategory;
  List<MovimentacaoModel> products = [];
  List<MovimentacaoModel> filteredProducts = [];
  String searchName = '';
  final ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _categories = await _productServices.fetchCategories();
    products = await _productServices.fetchMemberHistory(widget.membro.id);
    filteredProducts = products;
    setState(() {});
  }

  void filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchesName =
            product.Produto.toLowerCase().contains(searchName.toLowerCase());
        final matchesCategory =
            selectedCategory == null || product.categoria == selectedCategory;
        return matchesName && matchesCategory;
      }).toList();
    });
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
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(right: 30.0, left: 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.membro.name,
                                style: TextStyle(
                                    color: Color(0xFF01244E),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 40.sp),
                              ),
                              Text(
                                'Verifique o histórico de atividade e os produtos que estão com o colaborador:',
                                style: TextStyle(
                                    color: Color(0xffADBFD4),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25.sp),
                              )
                            ],
                          ),
                        ),
                        _containerAction(
                          ontap: () {},
                          color: Color(0xff4CC67A),
                          icon: Icons.bookmark_added,
                          text: 'Fechar e salvar',
                        )
                      ],
                    ),
                    SizedBox(
                      height: 25.sp,
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      children: [
                        Container(
                          height: 50.sp,
                          width: 570.sp,
                          decoration: BoxDecoration(
                            color: Color(0xffE3E8EE),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              SizedBox(
                                width: 10.sp,
                              ),
                              // Icon(
                              //   Icons.search,
                              //   color: Color(0xff8092A8),
                              // ),
                              // SizedBox(
                              //   width: 10.sp,
                              // ),
                              Expanded(
                                child: Container(
                                  height: 50.sp,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.search,
                                          color: Color(0xff8092A8)),
                                      hintText: "Encontra item pelo nome",
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24.sp,
                                        color: Color(0xffADBFD4),
                                      ),
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
                                ),
                              )
                              // Text(
                              //   "Encontra item pelo nome",
                              //   style: TextStyle(
                              //       fontWeight: FontWeight.w500,
                              //       fontSize: 24.sp,
                              //       color: Color(0xffADBFD4)),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20.sp,
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2(
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
                                .map((category) => DropdownMenuItem<String>(
                                      value: category['id'].toString(),
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.sp),
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
                              padding: EdgeInsets.symmetric(horizontal: 16.sp),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20.sp,
                        ),
                        widget.membro.isActive == true
                            ? _containerAction(
                                text: "Adicionar produto",
                                icon: Icons.add_circle_outline,
                                color: Color(0xffFEB100),
                                ontap: () {
                                  showDialog(
                                      barrierColor: Colors.transparent,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AddMemberProducts(
                                          membro: widget.membro,
                                        );
                                      });
                                },
                              )
                            : Container(),
                        SizedBox(
                          width: 10.sp,
                        ),
                        widget.membro.isActive == true
                            ? TooltipTheme(
                                data: TooltipThemeData(
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  preferBelow: false,
                                  verticalOffset: 20,
                                  showDuration: Duration(seconds: 2),
                                ),
                                child: Tooltip(
                                  message:
                                      'Ao clicar em adicionar produto, você poderá adicionar um novo produto no histórico de retirada e atividade deste usuário.',
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: 40,
                                    color: Color(0xffFEB100),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                    SizedBox(
                      height: 30.sp,
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      children: [
                        _containerHeader(
                            widthlarge: 2,
                            bordertopleft: 10,
                            borderTopRight: 0,
                            borderColor: Color(0xffE3E8EE),
                            texto: "Nome do item"),
                        _containerHeader(
                            bordertopleft: 0,
                            borderTopRight: 0,
                            borderColor: Color(0xffE3E8EE),
                            texto: 'Marca',
                            widthlarge: 1),
                        _containerHeader(
                            bordertopleft: 0,
                            borderTopRight: 0,
                            borderColor: Color(0xffE3E8EE),
                            texto: 'Categoria',
                            widthlarge: 2),
                        _containerHeader(
                            bordertopleft: 0,
                            borderTopRight: 0,
                            borderColor: Color(0xffE3E8EE),
                            texto: 'Movimentação',
                            widthlarge: 1),
                        _containerHeader(
                            bordertopleft: 0,
                            borderTopRight: 0,
                            borderColor: Color(0xffE3E8EE),
                            texto: 'Quantidade',
                            widthlarge: 1),
                        _containerHeader(
                            bordertopleft: 0,
                            borderTopRight: 0,
                            borderColor: Color(0xffE3E8EE),
                            texto: 'Status',
                            widthlarge: 1),
                        _containerHeader(
                            bordertopleft: 0,
                            borderTopRight: 0,
                            borderColor: Color(0xffE3E8EE),
                            texto: 'Retirada',
                            widthlarge: 1),
                        _containerHeader(
                            bordertopleft: 0,
                            borderTopRight: 10,
                            borderColor: Colors.transparent,
                            texto: 'Ações',
                            widthlarge: 1),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(),
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(0xffF0F4F8),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                        'lib/assets/animacao_user.json'),
                                    SizedBox(
                                      height: 50.sp,
                                    ),
                                    Text(
                                      'Nenhuma movimentação registrada',
                                      style: TextStyle(
                                          color: Color(0xff768AA1),
                                          fontSize: 30.sp,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return Ceduleproduct(
                                    product: product,
                                    membro: widget.membro,
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class Ceduleproduct extends StatefulWidget {
  final MovimentacaoModel product;
  final MemberModel membro;
  const Ceduleproduct({super.key, required this.product, required this.membro});

  @override
  State<Ceduleproduct> createState() => _CeduleproductState();
}

String formatarData(String dataISO) {
  DateTime data = DateTime.parse(dataISO);
  return DateFormat('dd/MM/yyyy HH:mm').format(data);
}

class _CeduleproductState extends State<Ceduleproduct> {
  Widget _buildContainer(String statusMovimentacao) {
    return statusMovimentacao == 'Devolvido'
        ? _containerCelulaActionView(
            // ontap: () {
            //   showPopover(

            //       barrierColor: Colors.transparent,
            //       context: context,
            //       bodyBuilder: (context) {
            //         return Container(
            //           height: 30.sp,
            //           width: 200.sp,
            //           color: Colors.amber,
            //         );
            //       });
            // },
            context: context,
            bordertopleft: 0,
            borderTopRight: 0,
            borderbottomRight: 0,
            borderbottomLeft: 0,
            borderColor: Colors.transparent,
            widthlarge: 1)
        : _containerCelulaAction(
            ontap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ReturnItensMember(
                      membro: widget.membro,
                      produto: widget.product,
                    );
                  });
            },
            context: context,
            bordertopleft: 0,
            borderTopRight: 0,
            borderbottomRight: 0,
            borderbottomLeft: 0,
            borderColor: Colors.transparent,
            widthlarge: 1);
  }

  @override
  Widget build(BuildContext context) {
    final int quantidadeReal =
        widget.product.Quantidade - widget.product.quantidadeDevolvidaAcumulada;
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Container(
            child: Column(
              children: [
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    _containerCelula(
                        bordertopleft: 0,
                        borderTopRight: 0,
                        borderbottomRight: 0,
                        borderbottomLeft: 0,
                        borderColor: Color.fromARGB(255, 40, 40, 41),
                        texto: widget.product.Produto,
                        widthlarge: 2),
                    _containerCelula(
                        bordertopleft: 0,
                        borderTopRight: 0,
                        borderbottomRight: 0,
                        borderbottomLeft: 0,
                        borderColor: Color.fromARGB(255, 40, 40, 41),
                        texto: widget.product.marca,
                        widthlarge: 1),
                    _containerCelula(
                        bordertopleft: 0,
                        borderTopRight: 0,
                        borderbottomRight: 0,
                        borderbottomLeft: 0,
                        borderColor: Color.fromARGB(255, 40, 40, 41),
                        texto: widget.product.categoria,
                        widthlarge: 2),
                    _containerCelula(
                        bordertopleft: 0,
                        borderTopRight: 0,
                        borderbottomRight: 0,
                        borderbottomLeft: 0,
                        borderColor: Color.fromARGB(255, 40, 40, 41),
                        texto: widget.product.statusMovimentacao,
                        widthlarge: 1),
                    _containerCelula(
                        bordertopleft: 0,
                        borderTopRight: 0,
                        borderbottomRight: 0,
                        borderbottomLeft: 0,
                        borderColor: Color.fromARGB(255, 40, 40, 41),
                        texto: quantidadeReal.toString(),
                        widthlarge: 1),
                    _containerCelulaStatus(
                        status: widget.product.status,
                        bordertopleft: 0,
                        borderTopRight: 0,
                        borderbottomRight: 0,
                        borderbottomLeft: 0,
                        borderColor: Color.fromARGB(255, 40, 40, 41),
                        widthlarge: 1),
                    _containerCelula(
                        bordertopleft: 0,
                        borderTopRight: 0,
                        borderbottomRight: 0,
                        borderbottomLeft: 0,
                        borderColor: Color.fromARGB(255, 40, 40, 41),
                        texto: formatarData(widget.product.dataMovimentacao),
                        widthlarge: 1),
                    _buildContainer(widget.product.statusMovimentacao)

                    // _containerCelulaAction(
                    //     ontap: () {
                    //       showDialog(
                    //           context: context,
                    //           builder: (BuildContext context) {
                    //             return ReturnItensMember(
                    //               membro: widget.membro,
                    //               produto: widget.product,
                    //             );
                    //           });
                    //     },
                    //     context: context,
                    //     bordertopleft: 0,
                    //     borderTopRight: 0,
                    //     borderbottomRight: 0,
                    //     borderbottomLeft: 0,
                    //     borderColor: Colors.transparent,
                    //     widthlarge: 1),
                  ],
                ),
                Container(
                  color: Color.fromARGB(255, 40, 40, 41),
                  height: 0.4,
                )
              ],
            ),
          );
        });
  }
}

Widget _containerHeader(
    {required double bordertopleft,
    required double borderTopRight,
    required Color borderColor,
    required String texto,
    required int widthlarge}) {
  return Expanded(
    flex: widthlarge,
    child: Container(
      height: 52.sp,
      // width: widthlarge,
      decoration: BoxDecoration(
        color: Color(0xff01244E),
        border: Border(
          right: BorderSide(
            color: borderColor,
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bordertopleft),
          topRight: Radius.circular(borderTopRight),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            texto,
            style: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: Colors.white,
                fontSize: 23.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    ),
  );
}

Widget _containerCelulaStatus(
    {required double bordertopleft,
    required double borderTopRight,
    required double borderbottomRight,
    required double borderbottomLeft,
    required Color borderColor,
    required int widthlarge,
    required String status}) {
  // Função para definir a cor e o ícone com base no status
  Map<String, dynamic> _statusInfo(String status) {
    switch (status) {
      case 'Novo':
        return {
          'color': Color(0xffB1F0C1),
          'textColor': Color(0xff4CC67A),
          'iconColor': Color(0xff4CC67A),
          'text': 'Novo',
        };
      case 'Usado':
        return {
          'color': Color(0xffEEDCB0),
          'textColor': Color(0xffDAA520),
          'iconColor': Color(0xffDAA520),
          'text': 'Usado',
        };
      case 'Danificado':
        return {
          'color': Color(0xffF0B1B1),
          'textColor': Color(0xffD9534F),
          'iconColor': Color(0xffD9534F),
          'text': 'Danificado',
        };
      default:
        return {
          'color': Color(0xffDBE1E9),
          'textColor': Color(0xffA0A6AD),
          'iconColor': Color(0xffA0A6AD),
          'text': 'Indefinido',
        };
    }
  }

  final statusInfo = _statusInfo(status);

  return Expanded(
    flex: widthlarge,
    child: Container(
      child: Container(
        height: 52.sp,
        decoration: BoxDecoration(
          color: Color(0xffDBE1E9),
          border: Border(
            right: BorderSide(color: borderColor, width: 0.3),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(bordertopleft),
            topRight: Radius.circular(borderTopRight),
            bottomLeft: Radius.circular(borderbottomLeft),
            bottomRight: Radius.circular(borderbottomRight),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 8),
            child: Container(
              // width: 100.sp,
              decoration: BoxDecoration(
                color: statusInfo['color'],
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.adjust,
                      color: statusInfo['iconColor'],
                    ),
                    SizedBox(
                      width: 5.sp,
                    ),
                    Text(
                      statusInfo['text'],
                      style: TextStyle(
                        color: statusInfo['textColor'],
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _containerCelulaAction(
    {required double bordertopleft,
    required double borderTopRight,
    required double borderbottomRight,
    required double borderbottomLeft,
    required Color borderColor,
    required GestureTapCallback ontap,
    required BuildContext context,
    required int widthlarge}) {
  return Expanded(
    flex: widthlarge,
    child: Container(
      // color: Colors.amber,
      child: Container(
        height: 52.sp,
        // width: widthlarge,
        decoration: BoxDecoration(
          color: Color(0xffDBE1E9),
          border: Border(
            // bottom: BorderSide(color: Color(0xffA0A6AD), width: 0.4),
            right: BorderSide(color: borderColor, width: 0.3),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(bordertopleft),
            topRight: Radius.circular(borderTopRight),
            bottomLeft: Radius.circular(borderbottomLeft),
            bottomRight: Radius.circular(borderbottomRight),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: InkWell(
              onTap: ontap,
              child: Container(
                width: 150.sp,
                decoration: BoxDecoration(
                    color: Color(0xffF25252),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Center(
                  child: Text(
                    'Devolver',
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _containerCelulaActionView({
  required double bordertopleft,
  required double borderTopRight,
  required double borderbottomRight,
  required double borderbottomLeft,
  required Color borderColor,
  required BuildContext context,
  required int widthlarge,
}) {
  return Expanded(
    flex: widthlarge,
    child: GestureDetector(
      onTap: () {
        showPopover(
          context: context,
          bodyBuilder: (context) => Stack(
            children: [
              Positioned(
                left: 30,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text('Conteúdo do Popover'),
                ),
              ),
            ],
          ),
          onPop: () => print('Popover fechado'),
          direction: PopoverDirection.left,
          width: 200,
          height: 100,
          arrowHeight: 10,
          arrowWidth: 20,
        );
      },
      child: Container(
        height: 52.sp,
        decoration: BoxDecoration(
          color: Color(0xffDBE1E9),
          border: Border(
            right: BorderSide(color: borderColor, width: 0.3),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(bordertopleft),
            topRight: Radius.circular(borderTopRight),
            bottomLeft: Radius.circular(borderbottomLeft),
            bottomRight: Radius.circular(borderbottomRight),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Container(
              width: 150.sp,
              decoration: BoxDecoration(
                color: Color(0xff4CC67A),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  'Ver',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _containerCelula(
    {required double bordertopleft,
    required double borderTopRight,
    required double borderbottomRight,
    required double borderbottomLeft,
    required Color borderColor,
    required String texto,
    required int widthlarge}) {
  return Expanded(
    flex: widthlarge,
    child: Container(
      // color: Colors.amber,
      child: Container(
        height: 52.sp,
        // width: widthlarge,
        decoration: BoxDecoration(
          color: Color(0xffDBE1E9),
          border: Border(
            // bottom: BorderSide(color: Color(0xffA0A6AD), width: 0.4),
            right: BorderSide(color: borderColor, width: 0.3),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(bordertopleft),
            topRight: Radius.circular(borderTopRight),
            bottomLeft: Radius.circular(borderbottomLeft),
            bottomRight: Radius.circular(borderbottomRight),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              // textAlign: TextAlign.start,
              texto,
              style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: Color(0xff889BB2),
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _containerAction(
    {required String text,
    required IconData icon,
    required Color color,
    required VoidCallback ontap}) {
  return InkWell(
    onTap: ontap,
    child: Container(
      height: 50.sp,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 25.sp,
              ),
              SizedBox(
                width: 5.sp,
              ),
              Text(
                text,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
