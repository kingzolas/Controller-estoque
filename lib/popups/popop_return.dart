import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopUpReturn extends StatelessWidget {
  // final String title;
  // final String content;
  final String nome;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PopUpReturn({
    Key? key,
    // required this.title,
    // required this.content,
    required this.nome,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AlertDialog(
            backgroundColor: Color(0xFFD2E3F7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Container(
              width: 520.sp,
              color: Color(0xFFD2E3F7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      height: 25.sp,
                      width: 25.sp,
                      child: Icon(PhosphorIcons.arrow_u_up_left)
                      // Image.asset('lib/assets/service_toolbox.png'),
                      ),
                  SizedBox(
                    width: 15.sp,
                  ),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Item devolvido pelo membro ',
                            style: TextStyle(
                              color: Color(0xFF3C4958),
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: nome,
                            style: TextStyle(
                              color: Color(0xFF01244E),
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: ', com ',
                            style: TextStyle(
                              color: Color(0xFF3C4958),
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: 'sucesso',
                            style: TextStyle(
                              color: Color(0xFF4BC57A),
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: '! ',
                            style: TextStyle(
                              color: Color(0xFF3C4958),
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
          );
        });
  }
}
