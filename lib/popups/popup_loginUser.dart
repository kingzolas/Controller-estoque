import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class PopupLoginuser extends StatefulWidget {
  final String nome;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PopupLoginuser({
    Key? key,
    required this.nome,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PopupLoginuser> createState() => _PopupLoginuserState();
}

class _PopupLoginuserState extends State<PopupLoginuser> {
  final Random _random = Random();

  String getSaudacao() {
    final horaAtual = DateTime.now().hour;

    List<String> mensagens;

    if (horaAtual >= 5 && horaAtual < 12) {
      mensagens = [
        'Bom dia, ${widget.nome}! Vamos fazer acontecer hoje.',
        'Bom dia, ${widget.nome}! Que seu dia seja produtivo.',
        'Bom dia, ${widget.nome}! Preparado para grandes conquistas?',
        'Bom dia, ${widget.nome}! Hoje é um ótimo dia para inovar.',
      ];
    } else if (horaAtual >= 12 && horaAtual < 18) {
      mensagens = [
        'Boa tarde, ${widget.nome}! Pronto para continuar?',
        'Boa tarde, ${widget.nome}! Vamos alcançar novos objetivos.',
        'Boa tarde, ${widget.nome}! A energia está no ponto certo.',
        'Boa tarde, ${widget.nome}! Que tal um sprint final no dia?',
      ];
    } else {
      mensagens = [
        'Boa noite, ${widget.nome}! Que tal revisar o dia?',
        'Boa noite, ${widget.nome}! Hora de refletir e recarregar.',
        'Boa noite, ${widget.nome}! Você fez um ótimo trabalho hoje.',
        'Boa noite, ${widget.nome}! Preparado para um descanso merecido?',
      ];
    }

    return mensagens[_random.nextInt(mensagens.length)];
  }

  String getIcon() {
    final horaAtual = DateTime.now().hour;

    if (horaAtual >= 5 && horaAtual < 12) {
      return "lib/assets/sol_dia.json";
      // Icons.light_mode; // Ícone para o dia
    } else if (horaAtual >= 12 && horaAtual < 18) {
      return "lib/assets/sol_meio-dia.json"; // Ícone para a tarde
    } else {
      return "lib/assets/lua_noite.json";
      // PhosphorIcons.moon_stars_fill; // Ícone para a noite
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
          backgroundColor: Color(0xFF01244E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            color: Color(0xFF01244E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 25.sp,
                  width: 25.sp,
                  child: Lottie.asset(getIcon()
                      // 'lib/assets/sol_meio-dia.json'
                      ),
                ),
                SizedBox(width: 15.sp),
                Flexible(
                  child: Text(
                    getSaudacao(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
