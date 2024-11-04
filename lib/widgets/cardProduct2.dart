import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product_model.dart';

class CardProduct2 extends StatefulWidget {
  final Product product;
  final String status;
  final int quantity;
  final int totalQuantity;
  final GestureTapCallback ontap;
  final Widget? child; // Novo parâmetro para receber um widget filho

  const CardProduct2({
    Key? key,
    required this.ontap,
    required this.product,
    required this.status,
    required this.quantity,
    required this.totalQuantity,
    this.child, // Parâmetro opcional
  }) : super(key: key);

  @override
  _CardProduct2State createState() => _CardProduct2State();
}

class _CardProduct2State extends State<CardProduct2> {
  bool _isChildVisible = false; // Estado para controlar a visibilidade do child

  void _toggleChildVisibility() {
    setState(() {
      _isChildVisible = !_isChildVisible; // Alterna a visibilidade
    });
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
          child: GestureDetector(
            onTap: () {
              _toggleChildVisibility(); // Alterna a visibilidade ao clicar
              widget.ontap(); // Chama a função onTap passada como parâmetro
            },
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
                  Container(
                    height: 70,
                    width: 200,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: containerStatus(status: widget.status),
                    ),
                  ),
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
                  // Exibir o widget child se fornecido e se estiver visível
                  if (_isChildVisible && widget.child != null) widget.child!,
                ],
              ),
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
                fontSize: 20.sp,
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
                fontSize: 20.sp,
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
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
  }
}
