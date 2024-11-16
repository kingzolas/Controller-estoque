import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopupCreateproduct extends StatefulWidget {
  // final String title;
  // final String content;
  final String nome;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PopupCreateproduct({
    Key? key,
    // required this.title,
    // required this.content,
    required this.nome,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PopupCreateproduct> createState() => _PopupCreatememberState();
}

class _PopupCreatememberState extends State<PopupCreateproduct> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AlertDialog(
            backgroundColor: Color(0xFF01244E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Container(
              width: 520.sp,
              color: Color(0xFF01244E),
              child: Container(
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 25.sp,
                      width: 25.sp,
                      child: Icon(
                        Icons.inventory_2,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      // child: Image.asset('lib/assets/service_toolbox.png'),
                    ),
                    SizedBox(
                      width: 15.sp,
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Cadastro realizado: ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text: widget.nome,
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text: ' agora está disponível no ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text: 'estoque',
                              style: TextStyle(
                                color: Color(0xFF4BC57A),
                                fontSize: 18.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            TextSpan(
                              text: '!',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
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
            ),
          );
        });
  }
}
