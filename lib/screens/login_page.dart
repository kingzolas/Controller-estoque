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

  @override
  void initState() {
    super.initState();
    _checkAppVersion();
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
                height: 10,
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
                                BorderRadius.all(Radius.circular(20))),
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
                              height: 1.sp)),
                      SizedBox(
                        height: 15.sp,
                      ),
                      Text(
                        'Acesse e gerencie o histórico de movimentação da   sua empresa, de forma rápida e prática.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF01244E),
                            fontSize: 18.sp,
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w600,
                            height: 1.sp),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
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
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Usuário',
                                    hintStyle: TextStyle(
                                      height: 3.4.sp,
                                      color: Color(0x72889BB2),
                                      fontSize: 20.sp,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
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
                                              BorderRadius.circular(3)),
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
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Senha',
                                          hintStyle: TextStyle(
                                            height: 3.4.sp,
                                            color: Color(0x72889BB2),
                                            fontSize: 20.sp,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Entrar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // child: Container(
                //   decoration: BoxDecoration(
                //     color: const Color.fromARGB(255, 11, 11, 179),
                //     borderRadius: BorderRadius.all(Radius.circular(20)),
                //   ),
                //   height: 600.sp,
                //   width: 450.sp,
                //   padding: EdgeInsets.all(20.sp),
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       Text(
                //         "Faça Login",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 28.sp,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       SizedBox(height: 30.sp),

                //       // Campo de usuário
                //       Container(
                //         height: 50.sp,
                //         width: 350.sp,
                //         decoration: BoxDecoration(
                //           color: const Color(0xff383838),
                //           borderRadius: BorderRadius.all(Radius.circular(10)),
                //         ),
                //         child: TextFormField(
                //           controller: _usernameController,
                //           style: TextStyle(color: Colors.white),
                //           textAlignVertical: TextAlignVertical.center,
                //           decoration: InputDecoration(
                //             hintText: "Usuário",
                //             hintStyle: TextStyle(color: Colors.grey[400]),
                //             prefixIcon: Icon(Icons.person, color: Colors.white),
                //             border: InputBorder.none,
                //             contentPadding: EdgeInsets.symmetric(
                //                 horizontal: 15.sp, vertical: 15.sp),
                //           ),
                //         ),
                //       ),

                //       SizedBox(height: 20.sp),

                //       // Campo de senha
                //       Container(
                //         height: 50.sp,
                //         width: 350.sp,
                //         decoration: BoxDecoration(
                //           color: const Color(0xff383838),
                //           borderRadius: BorderRadius.all(Radius.circular(10)),
                //         ),
                //         child: TextFormField(
                //           controller: _passwordController,
                //           obscureText: !_isPasswordVisible,
                //           style: TextStyle(color: Colors.white),
                //           textAlignVertical: TextAlignVertical.center,
                //           decoration: InputDecoration(
                //             hintText: "Senha",
                //             hintStyle: TextStyle(color: Colors.grey[400]),
                //             prefixIcon: Icon(Icons.lock, color: Colors.white),
                //             suffixIcon: IconButton(
                //               icon: Icon(
                //                 _isPasswordVisible
                //                     ? Icons.visibility
                //                     : Icons.visibility_off,
                //                 color: Colors.white,
                //               ),
                //               onPressed: () {
                //                 setState(() {
                //                   _isPasswordVisible = !_isPasswordVisible;
                //                 });
                //               },
                //             ),
                //             border: InputBorder.none,
                //             contentPadding: EdgeInsets.symmetric(
                //                 horizontal: 15.sp, vertical: 15.sp),
                //           ),
                //         ),
                //       ),

                //       SizedBox(height: 30.sp),

                //       // Botão de login
                //       SizedBox(
                //         width: 350.sp,
                //         height: 50.sp,
                //         child: ElevatedButton(
                //           onPressed: () async {
                //             String email = _usernameController.text.trim();
                //             String password = _passwordController.text.trim();
                //             await login(email, password);
                //           },
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: const Color(0xff00A86B),
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //           ),
                //           child: Text(
                //             "Login",
                //             style: TextStyle(
                //               fontSize: 18.sp,
                //               fontWeight: FontWeight.bold,
                //               color: Colors.white,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    // color: Colors.amber,
                    height: 40,
                    width: 90,
                    child: Text(
                      "Versão${AppVersion.version}",
                      style: TextStyle(color: Colors.white, fontSize: 15),
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
