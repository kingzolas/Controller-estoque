import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/dashboard.dart';
import 'package:velocityestoque/popups/popup_atualizacao.dart';
import '../models/auth_provider.dart';
import '../popups/popup_loginUser.dart';
import '../version/app_version.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final Map<String, List<OverlayEntry>> activePopupsMap =
      {}; // Associa popups a cada membro

  void showCustomPopup(BuildContext context, String memberId) {
    OverlayState overlayState = Overlay.of(context)!;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        // Obtém a lista de popups para o membro específico
        List<OverlayEntry> memberPopups = activePopupsMap[memberId] ?? [];
        int index = memberPopups.indexOf(overlayEntry);
        return Positioned(
          right: 20,
          bottom: 20 + (index * 80), // Empilha verticalmente
          child: Material(
            color: Colors.transparent,
            child: PopupLoginuser(
              nome: memberId,
              onConfirm: () {
                overlayEntry.remove();
                memberPopups.remove(overlayEntry);
                _updatePopupPositions(memberId);
              },
              onCancel: () {
                overlayEntry.remove();
                memberPopups.remove(overlayEntry);
                _updatePopupPositions(memberId);
              },
            ),
          ),
        );
      },
    );

    // Adiciona o popup ao mapa do membro correspondente
    activePopupsMap.putIfAbsent(memberId, () => []).add(overlayEntry);
    overlayState.insert(overlayEntry);

    // Fecha automaticamente após 10 segundos
    Future.delayed(Duration(seconds: 10), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        activePopupsMap[memberId]?.remove(overlayEntry);
        _updatePopupPositions(memberId);
      }
    });
  }

// Método para reposicionar os popups de um membro específico
  void _updatePopupPositions(String memberId) {
    List<OverlayEntry>? memberPopups = activePopupsMap[memberId];
    if (memberPopups != null) {
      for (var i = 0; i < memberPopups.length; i++) {
        memberPopups[i].markNeedsBuild();
      }
    }
  }

  Future<void> login(String email, String password) async {
    final url =
        Uri.parse('${Config.apiUrl}/api/login'); // Use o URL do seu servidor

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Resposta do servidor: ${response.body}'); // Imprimir resposta

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Login bem-sucedido: ${responseData['msg']}');

        // Verifique se o usuário está presente na resposta
        if (responseData['user'] != null) {
          final user = responseData['user'];
          String userId = user['_id'];
          String userName = user['name'];
          String oficcer = user['oficcer'];

          // Salvar as informações do usuário no Provider
          Provider.of<AuthProvider>(context, listen: false).login(
            userId, userName, oficcer, email, password,
            // Você pode armazenar o email, se necessário
          );

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Login efetuado com sucesso!'),
          //     backgroundColor: Colors.green,
          //   ),
          // );
          showCustomPopup(context, userName);

          // Navegar para a tela de dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        } else {
          print('Erro: Dados do usuário não encontrados.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: Dados do usuário não encontrados.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final responseData = json.decode(response.body);
        print('Erro de login: ${responseData['msg']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${responseData['msg']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Erro ao conectar ao servidor: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao conectar ao servidor.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String serverVersion = '';

  Future<void> _checkAppVersion() async {
    final url =
        Uri.parse('${Config.apiUrl}/api/latest-version'); // Atualize o URL
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final serverData = json.decode(response.body);

        setState(() {
          serverVersion = serverData['version'];
        });

        if (AppVersion.version.compareTo(serverVersion) < 0) {
          _showUpdateDialog();
        }
      } else {
        print('Erro ao buscar versão do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao conectar ao servidor: $e');
    }
  }

  void _showUpdateDialog() {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopupAtualizacao(
          versao: serverVersion,
        );
      },
    );
  }

  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkAppVersion();
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xff01244E),
          // body: PopupAtualizacao(
          //   versao: serverVersion,
          // ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 10.sp,
              ),
              Center(
                child: Container(
                  height: 680.sp,
                  width: 580.sp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.sp),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 70.sp,
                      ),
                      Container(
                        height: 115.sp,
                        width: 115.sp,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: const Color.fromARGB(92, 0, 0, 0),
                                  blurRadius: 4.sp,
                                  offset: Offset(0, 5),
                                  blurStyle: BlurStyle.normal)
                            ],
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.sp))),
                        child: Center(
                          child: Container(
                            height: 70.sp,
                            width: 70.sp,
                            child: Image.asset(
                              'lib/assets/logoVelocity.png',
                              // scale: 74.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 45.sp,
                      ),
                      Text('Seja bem-vindo ao\nVelocitynet Estoque!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                              color: Color(0xFF01244E),
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w900,
                              height: 0.sp)),
                      SizedBox(
                        height: 15.sp,
                      ),
                      Text(
                        'Acesse e gerencie o histórico de movimentação da   sua empresa, de forma rápida e prática.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                            color: Color(0xFF01244E),
                            fontSize: 18.sp,
                            // fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w600,
                            height: 0.sp),
                      ),
                      SizedBox(
                        height: 30.sp,
                      ),
                      Container(
                        width: 490.sp,
                        height: 60.sp,
                        decoration: ShapeDecoration(
                          color: Color(0xFFE3E8EE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIcons.user_circle_fill,
                                size: 26.sp,
                                color: Color(0xff889BB2),
                              ),
                              SizedBox(
                                width: 15.sp,
                              ),
                              Container(
                                height: 60.sp,
                                width: 400.sp,
                                child: TextFormField(
                                  controller: _usernameController,
                                  focusNode: _usernameFocusNode,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Usuário',
                                    hintStyle: GoogleFonts.roboto(
                                      height: 3.4.sp,
                                      color: Color(0x72889BB2),
                                      fontSize: 20.sp,
                                      // fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onFieldSubmitted: (_) {
                                    // Ao pressionar "Enter", muda o foco para o campo de senha
                                    FocusScope.of(context)
                                        .requestFocus(_passwordFocusNode);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.sp,
                      ),
                      Container(
                        width: 490.sp,
                        height: 60.sp,
                        decoration: ShapeDecoration(
                          color: Color(0xFFE3E8EE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // SizedBox(
                              //   width: 20.sp,
                              // ),
                              Container(
                                child: Row(
                                  children: [
                                    Container(
                                      height: 28.sp,
                                      width: 35.sp,
                                      decoration: BoxDecoration(
                                          color: Color(0xff889BB2),
                                          borderRadius:
                                              BorderRadius.circular(3.sp)),
                                      child: Center(
                                        child: Icon(
                                          PhosphorIcons.password_bold,
                                          color: Color(0xffE3E8EE),
                                          size: 26.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.sp,
                                    ),
                                    Container(
                                      height: 60.sp,
                                      width: 300.sp,
                                      child: TextFormField(
                                        obscureText: !_isPasswordVisible,
                                        controller: _passwordController,
                                        focusNode:
                                            _passwordFocusNode, // Adicione o FocusNode ao campo de senha
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Senha',
                                          hintStyle: GoogleFonts.roboto(
                                            height: 3.4.sp,
                                            color: Color(0x72889BB2),
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onFieldSubmitted: (_) {
                                          String email =
                                              _usernameController.text.trim();
                                          String password =
                                              _passwordController.text.trim();
                                          login(email,
                                              password); // Execute a função de login ao pressionar Enter
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Color(0x72889BB2),
                                  size: 25.sp,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50.sp,
                      ),
                      InkWell(
                        onTap: () async {
                          String email = _usernameController.text.trim();
                          String password = _passwordController.text.trim();
                          await login(email, password);
                        },
                        child: Container(
                          width: 490.sp,
                          height: 60.sp,
                          decoration: ShapeDecoration(
                            color: Color(0xFFFEB100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.sp),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Entrar',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontSize: 22.sp,
                                // fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    // color: Colors.amber,
                    height: 40.sp,
                    width: 90.sp,
                    child: Text(
                      "Versão${AppVersion.version}",
                      style: TextStyle(color: Colors.white, fontSize: 15.sp),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
