import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopupAddproduct extends StatefulWidget {
  final int quantidade; // Alterado para int para facilitar a comparação
  final String nome;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PopupAddproduct({
    Key? key,
    required this.quantidade,
    required this.nome,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PopupAddproduct> createState() => _PopupAddproductState();
}

class _PopupAddproductState extends State<PopupAddproduct> {
  String getQuantidadeTexto() {
    // Verifica se a quantidade é maior que 1 e ajusta a palavra para o plural
    if (widget.quantidade > 1) {
      return "${widget.quantidade} unidades";
    } else {
      return "${widget.quantidade} unidade";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AlertDialog(
            backgroundColor: Color(0xFF4CC67A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Container(
              width: 520.sp,
              color: Color(0xFF4CC67A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 30.sp,
                    width: 30.sp,
                    child:
                        Icon(PhosphorIcons.package_fill, color: Colors.white),
                  ),
                  SizedBox(
                    width: 15.sp,
                  ),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${getQuantidadeTexto()} ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: 'de ${widget.nome} ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text:
                                'adicionada${widget.quantidade > 1 ? "s" : ""} ao estoque com ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: 'sucesso',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
