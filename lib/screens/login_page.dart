import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/dashboard.dart';
import '../models/auth_provider.dart';
import '../popups/popup_loginUser.dart'; // Importar o AuthProvider

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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login efetuado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
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
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xff202020),
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff333334),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              height: 600.sp,
              width: 450.sp,
              padding: EdgeInsets.all(20.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Faça Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30.sp),

                  // Campo de usuário
                  Container(
                    height: 50.sp,
                    width: 350.sp,
                    decoration: BoxDecoration(
                      color: const Color(0xff383838),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: Colors.white),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Usuário",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 15.sp, vertical: 15.sp),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.sp),

                  // Campo de senha
                  Container(
                    height: 50.sp,
                    width: 350.sp,
                    decoration: BoxDecoration(
                      color: const Color(0xff383838),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: TextStyle(color: Colors.white),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Senha",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 15.sp, vertical: 15.sp),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.sp),

                  // Botão de login
                  SizedBox(
                    width: 350.sp,
                    height: 50.sp,
                    child: ElevatedButton(
                      onPressed: () async {
                        String email = _usernameController.text.trim();
                        String password = _passwordController.text.trim();
                        await login(email, password);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00A86B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
