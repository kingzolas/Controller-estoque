import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopupUpdateinfoproduct extends StatefulWidget {
  // final int quantidade; // Alterado para int para facilitar a comparação
  final String nome;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PopupUpdateinfoproduct({
    Key? key,
    // required this.quantidade,
    required this.nome,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PopupUpdateinfoproduct> createState() => _PopupAddproductState();
}

class _PopupAddproductState extends State<PopupUpdateinfoproduct> {
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
              width: double.infinity,
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
                            text: "Informações do item",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: ' "${widget.nome}"',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: ' atualizadas com ',
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
