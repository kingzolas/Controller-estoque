import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopupUpdatemember extends StatefulWidget {
  // final String title;
  // final String content;
  // final String nome;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PopupUpdatemember({
    Key? key,
    // required this.title,
    // required this.content,
    // required this.nome,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PopupUpdatemember> createState() => _PopupCreatememberState();
}

class _PopupCreatememberState extends State<PopupUpdatemember> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AlertDialog(
            backgroundColor: Color(0xFFFEB100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Container(
              // width: 520.sp,
              color: Color(0xFFFEB100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 25.sp,
                    width: 25.sp,
                    child: Icon(
                      Icons.badge,
                      color: Color(0xff1C1B1F),
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
                            text: 'Parabéns! ',
                            style: TextStyle(
                              color: Color(0xFF01244E),
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text:
                                'as informações do colaborador foram atualizadas com',
                            style: TextStyle(
                              color: Color(0xFF3C4958),
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: ' sucesso',
                            style: TextStyle(
                              color: Color(0xFF01244E),
                              fontSize: 18.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: '!',
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
