import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlertDialogErroDevolucao extends StatefulWidget {
  final String name;
  final String quantidade;
  final GestureTapCallback ontapTrue;
  final GestureTapCallback ontapFalse;
  const AlertDialogErroDevolucao(
      {super.key,
      required this.name,
      required this.quantidade,
      required this.ontapTrue,
      required this.ontapFalse});

  @override
  State<AlertDialogErroDevolucao> createState() =>
      _AlertDialogErroDevolucaoState();
}

class _AlertDialogErroDevolucaoState extends State<AlertDialogErroDevolucao> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AlertDialog(
            backgroundColor: Color(0xff01244E),
            content: Container(
              padding: EdgeInsets.all(15),
              height: 300.sp,
              width: 770.sp,
              decoration: BoxDecoration(
                color: Color(0xff01244E),
                borderRadius: BorderRadius.all(
                  Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Devolução Excedente',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 45.sp,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w800,
                      height: 0,
                    ),
                  ),
                  SizedBox(
                    height: 25.sp,
                  ),
                  SizedBox(
                    width: 680.sp,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'O número de itens ',
                            style: TextStyle(
                              color: Color(0xFFC7CED8),
                              fontSize: 25.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: 'devolvidos',
                            style: TextStyle(
                              color: Color(0xFFF25151),
                              fontSize: 25.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' excede a quantidade retirada. Certifique-se de devolver no máximo ',
                            style: TextStyle(
                              color: Color(0xFFC7CED8),
                              fontSize: 25.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: '${widget.quantidade} unidades',
                            style: TextStyle(
                              color: Color(0xFFFEB100),
                              fontSize: 25.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: ' de ',
                            style: TextStyle(
                              color: Color(0xFFC7CED8),
                              fontSize: 25.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: widget.name,
                            style: TextStyle(
                              color: Color(0xFF4BC57A),
                              fontSize: 25.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                            style: TextStyle(
                              color: Color(0xFFC7CED8),
                              fontSize: 25.sp,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: widget.ontapFalse,
                        child: Container(
                          width: 265.sp,
                          height: 60.sp,
                          decoration: ShapeDecoration(
                            color: Color(0xFFF25151),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9.23),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Descartar alterações',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: widget.ontapTrue,
                        child: Container(
                          width: 265.sp,
                          height: 60.sp,
                          decoration: ShapeDecoration(
                            color: Color(0xFF4BC57A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9.23),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Continuar editando',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
