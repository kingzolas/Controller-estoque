import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../models/product_model.dart';

class Cardproduct extends StatefulWidget {
  final Product product;
  final String status;
  final int quantity;
  final int totalQuantity;
  final GestureTapCallback ontap;
  final GestureTapCallback edit;

  const Cardproduct({
    super.key,
    required this.edit,
    required this.ontap,
    required this.product,
    required this.status,
    required this.quantity,
    required this.totalQuantity,
  });

  @override
  _CardproductState createState() => _CardproductState();
}

class _CardproductState extends State<Cardproduct>
    with TickerProviderStateMixin {
  late AnimationController _editController;
  late AnimationController _addController;

  @override
  void initState() {
    super.initState();

    // Inicializando os controladores de animação
    _editController = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 1), // Durarão 1 segundo ou o tempo que você preferir
    );

    _addController = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 1), // Durarão 1 segundo ou o tempo que você preferir
    );
  }

  @override
  void dispose() {
    // Libere os controladores de animação ao finalizar
    _editController.dispose();
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 90.sp,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xffDBE1E9),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Informações do Produto
                Container(
                  height: 70.sp,
                  width: 350.sp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          color: Color(0xFF68798D),
                          overflow: TextOverflow.ellipsis,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.product.marca,
                        style: TextStyle(
                          color: Color(0xFF889BB2),
                          fontSize: 20.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status do Produto
                Container(
                    height: 70,
                    width: 200,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: containerStatus(status: widget.status))),
                // Categoria
                Container(
                  height: 70.sp,
                  width: 350.sp,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.product.category,
                      style: TextStyle(
                        color: Color(0xFF889BB2),
                        fontSize: 20.sp,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  ),
                ),
                // Quantidades
                Container(
                  width: 220.sp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Quant. Total | ',
                              style: TextStyle(
                                color: Color(0xFF889BB2),
                                fontSize: 20.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text: widget.totalQuantity.toString(),
                              style: TextStyle(
                                color: Color(0xFF68798D),
                                fontSize: 20.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Quant. ${widget.status == 'novo' ? 'Novos' : widget.status == 'usado' ? 'Usados' : 'Danificados'} | ',
                              style: TextStyle(
                                color: Color(0xFF889BB2),
                                fontSize: 19.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text: widget.quantity.toString(),
                              style: TextStyle(
                                color: Color(0xFF68798D),
                                fontSize: 19.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Botões
                Row(
                  children: [
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _editController
                              .repeat(); // Inicia a animação ao passar o mouse
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _editController
                              .reset(); // Reseta a animação ao retirar o mouse
                        });
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: widget.edit,
                          child: Container(
                            height: 50.sp,
                            width: 50.sp,
                            alignment: Alignment.center,
                            child: Lottie.asset(
                              'lib/assets/pencil_6454112.json',
                              height: 30.sp,
                              width: 30.sp,
                              controller: _editController,
                              repeat:
                                  false, // Impede que repita automaticamente
                              animate: _editController
                                  .isAnimating, // Controla a animação com o controller
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Botão de adição
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _addController
                              .repeat(); // Inicia a animação ao passar o mouse
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _addController
                              .reset(); // Reseta a animação ao retirar o mouse
                        });
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: widget.ontap,
                          child: Container(
                            height: 50.sp,
                            width: 50.sp,
                            alignment: Alignment.center,
                            child: Lottie.asset(
                              'lib/assets/add_16046411.json',
                              height: 50.sp,
                              width: 50.sp,
                              controller: _addController,
                              repeat:
                                  false, // Impede que repita automaticamente
                              animate: _addController
                                  .isAnimating, // Controla a animação com o controller
                            ),
                          ),
                        ),
                      ),
                    ),
                    // IconButton(
                    //   onPressed: widget.ontap,
                    //   icon: Icon(
                    //     Icons.add,
                    //     color: Color(0xff4CC67A),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget containerStatus({required String status}) {
  switch (status) {
    case 'novo':
      return Container(
        height: 45.sp,
        width: 100.sp,
        decoration: BoxDecoration(
          color: Color(0xffB1F0C1),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        // padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.adjust,
              color: Color(0xff4CC67A),
              size: 19.sp,
            ),
            SizedBox(width: 8.0),
            Text(
              'Novo',
              style: TextStyle(
                color: Color(0xff4CC67A),
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

    case 'usado':
      return Container(
        height: 45.sp,
        width: 110.sp,
        decoration: BoxDecoration(
          color: Color(0xffEEDCB0),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        // padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.adjust,
              color: Color(0xffDAA520),
              size: 19.sp,
            ),
            SizedBox(width: 8.0),
            Text(
              'Usado',
              style: TextStyle(
                color: Color(0xffDAA520),
                fontSize: 20.sp, // Ajuste o tamanho conforme necessário
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

    case 'danificado':
      return Container(
        height: 45.sp,
        width: 150.sp,
        decoration: BoxDecoration(
          color: Color(0xffF0B1B1),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        // padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.adjust,
              color: Color(0xffD9534F),
              size: 19.sp,
            ),
            SizedBox(width: 8.0),
            Text(
              'Danificado',
              style: TextStyle(
                color: Color(0xffD9534F),
                fontSize: 20.sp, // Ajuste o tamanho conforme necessário
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

    default:
      return Container(
        decoration: BoxDecoration(
          color: Color(0xffDBE1E9),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.adjust,
              color: Color(0xffA0A6AD),
            ),
            SizedBox(width: 8.0),
            Text(
              'Indefinido',
              style: TextStyle(
                color: Color(0xffA0A6AD),
                fontSize: 16.sp, // Ajuste o tamanho conforme necessário
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
  }
}
