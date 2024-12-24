import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoricTable extends StatefulWidget {
  final String StatusItem;
  final String id;
  final String Item;
  final String Movimentacao;
  final int Quantidade;
  final String DataMovimentacao;
  final String Marca;
  String? Membro;
  final String Usuario;
  final String data;
  final String hora;
  final int index;

  HistoricTable(
      {super.key,
      required this.data,
      required this.hora,
      required this.Marca,
      required this.StatusItem,
      required this.Item,
      required this.Movimentacao,
      required this.Quantidade,
      required this.DataMovimentacao,
      required this.Usuario,
      required this.index,
      this.Membro,
      required this.id});

  @override
  State<HistoricTable> createState() => _HistoricTableState();
}

class _HistoricTableState extends State<HistoricTable> {
  final Color containerColor = Color(0xffDBE1E9);
  final Color textColor = Color(0xFF889BB2);
  final Color strokeColor = Color(0xFF889BB2);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Container(
            height: 70.sp,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Container(
                  height: 70.sp,
                  width: 60.sp,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: strokeColor, strokeAlign: 0.1.sp),
                        right: BorderSide(
                            color: strokeColor, strokeAlign: 0.1.sp)),
                    color: containerColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0.1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${widget.index}",
                      style: TextStyle(
                          color: textColor,
                          fontSize: 24.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.only(left: 30.sp),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp),
                          right: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp)),
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.1),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.Item,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 24.sp,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            height: 0,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(left: 30.sp),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: strokeColor, strokeAlign: 0.1.sp),
                        right:
                            BorderSide(color: strokeColor, strokeAlign: 0.1.sp),
                      ),
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.1),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.Marca,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(5.sp),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp),
                          right: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp)),
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.1),
                      ),
                    ),
                    child: Align(
                        alignment: Alignment.center,
                        child: containerStatus(status: widget.StatusItem)),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    // padding: EdgeInsets.only(left: 30.sp),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp),
                          right: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp)),
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.1),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.Movimentacao,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(5.sp),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp),
                          right: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp)),
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.1),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.Quantidade.toString(),
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: textColor,
                          fontSize: 24.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(left: 30.sp),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp),
                          right: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp)),
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.1),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.data,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(5.sp),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp),
                          right: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp)),
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.1),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.hora,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(left: 30.sp),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp),
                          right: BorderSide(
                              color: strokeColor, strokeAlign: 0.1.sp)),
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(0.1),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.Usuario,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(left: 20.sp),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: strokeColor, strokeAlign: 0.1.sp),
                        // right: BorderSide(
                        //     color: Colors.transparent, strokeAlign: 0),
                      ),
                      color: containerColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(0.1),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.Membro.toString(),
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: textColor,
                          fontSize: 24.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

Widget containerStatus({required String status}) {
  switch (status) {
    case 'Novo':
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

    case 'Usado':
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

    case 'Danificado':
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
                  overflow: TextOverflow.ellipsis),
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
