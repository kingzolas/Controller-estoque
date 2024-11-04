import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:velocityestoque/models/user_model.dart';

import '../models/auth_provider.dart';
import '../models/product_model.dart';
// import '../services/product_services.dart';
import '../services/products_services.dart'; // Importe o serviço aqui

class AddProduct extends StatefulWidget {
  final Product produto;
  const AddProduct({super.key, required this.produto});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController _quantityController =
      TextEditingController(text: '0');
  String _selectedStatus = 'Novo';

  void _incrementQuantity() {
    setState(() {
      int currentQuantity = int.tryParse(_quantityController.text) ?? 0;
      currentQuantity++;
      _quantityController.text = currentQuantity.toString();
    });
  }

  void _decrementQuantity() {
    setState(() {
      int currentQuantity = int.tryParse(_quantityController.text) ?? 0;
      if (currentQuantity > 0) {
        currentQuantity--;
      }
      _quantityController.text = currentQuantity.toString();
    });
  }

  Future<void> _addProduct({required String userId}) async {
    final int quantity = int.tryParse(_quantityController.text) ?? 0;

    try {
      // Verifique o status selecionado e chame a função apropriada de ProductServices
      if (_selectedStatus == 'Novo') {
        await ProductServices('ws://192.168.99.239:3000')
            .updateNewProductQuantity(
                widget.produto.id, quantity, userId, 'ENTRADA');
      } else if (_selectedStatus == 'Usado') {
        await ProductServices('ws://192.168.99.239:3000')
            .updateUsedProductQuantity(
                widget.produto.id, quantity, userId, 'ENTRADA');
      } else if (_selectedStatus == 'Danificado') {
        await ProductServices('ws://192.168.99.239:3000')
            .updateDamagedProductQuantity(
                widget.produto.id, quantity, userId, 'ENTRADA');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto atualizado com sucesso!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar produto: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AlertDialog(
            content: Container(
              height: 550,
              width: 1030,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 50.sp,
                          width: 620.sp,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Adicionar ',
                                  style: TextStyle(
                                    color: Color(0xFF01244E),
                                    fontSize: 40.sp,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                    text: widget.produto.name,
                                    style: TextStyle(
                                      color: Color(0xFF01244E),
                                      fontSize: 40.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (true) {
                              final String userId = authProvider.userId ?? '';
                              _addProduct(userId: userId);
                            }
                          },
                          // _addProduct, // Chama a função ao clicar em "Adicionar"
                          child: Container(
                            height: 50.sp,
                            width: 160.sp,
                            decoration: BoxDecoration(
                              color: Color(0xff4CC67A),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Center(
                              child: Text(
                                'Adicionar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30.sp,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Quantidade: ',
                              style: TextStyle(
                                color: Color(0xFF889BB2),
                                fontSize: 20.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Informe a quantidade de item que está sendo devolvido',
                              style: TextStyle(
                                color: Color(0xFFADBFD4),
                                fontSize: 20.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w300,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.sp,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 60.sp,
                        width: 150.sp,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F4F8),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _quantityController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: Color(0xFF01244E),
                                  fontSize: 25,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (value) {
                                  setState(() {
                                    int currentQuantity =
                                        int.tryParse(value) ?? 00;
                                    _quantityController.text =
                                        currentQuantity.toString();
                                  });
                                },
                              ),
                            ),
                            // Text(
                            //   '00',
                            //   style: TextStyle(
                            //     color: Color(0xFF01244E),
                            //     fontSize: 25,
                            //     fontFamily: 'Roboto',
                            //     fontWeight: FontWeight.w700,
                            //     height: 0,
                            //   ),
                            // ),
                            SizedBox(
                              width: 30.sp,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _incrementQuantity,
                                  child: Container(
                                    height: 20.sp,
                                    width: 20.sp,
                                    decoration: BoxDecoration(
                                      color: Color(0xffDBE1E9),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: Icon(Icons.keyboard_arrow_up,
                                        size: 20.sp),
                                  ),
                                ),
                                SizedBox(height: 10.sp),
                                GestureDetector(
                                  onTap: _decrementQuantity,
                                  child: Container(
                                    height: 20.sp,
                                    width: 20.sp,
                                    decoration: BoxDecoration(
                                      color: Color(0xffDBE1E9),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 20.sp),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.sp,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Status: ',
                              style: TextStyle(
                                color: Color(0xFF889BB2),
                                fontSize: 20.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Informe o status do item que está sendo devolvido',
                              style: TextStyle(
                                color: Color(0xFFADBFD4),
                                fontSize: 20.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w300,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.sp,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 60.sp,
                        width: 200.sp,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F4F8),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                _selectedStatus, // Variável para armazenar o valor selecionado
                            items: <String>['Novo', 'Usado', 'Danificado']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.adjust,
                                      color: value == 'Novo'
                                          ? Color(0xff4CC67A)
                                          : value == 'Usado'
                                              ? Color(0xffFFA726)
                                              : Color(0xffF44336),
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.sp),
                                    Text(
                                      value,
                                      style: TextStyle(
                                        color: value == 'Novo'
                                            ? Color(0xFF4BC57A)
                                            : value == 'Usado'
                                                ? Color(0xFFFFA726)
                                                : Color(0xFFF44336),
                                        fontSize: 19.sp,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStatus = newValue!;
                              });
                            },
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 30.sp,
                              color: Color(0xff889BB2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.sp,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Descrição: ',
                              style: TextStyle(
                                color: Color(0xFF889BB2),
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Informe as condições em que o item está sendo devolvido',
                              style: TextStyle(
                                color: Color(0xFFADBFD4),
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w300,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.sp,
                    ),
                    Container(
                      width: double.infinity,
                      height: 164,
                      decoration: ShapeDecoration(
                        color: Color(0xFFF0F4F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
