import 'package:http/http.dart' as http;
import 'dart:convert';

import '../baseConect.dart';

Future<void> login(String email, String password) async {
  final url =
      Uri.parse('${Config.apiUrl}/api/login'); // Use o URL do seu servidor

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Aqui você pode lidar com a resposta do servidor
      print('Login bem-sucedido: ${responseData['message']}');
      // Exiba uma mensagem de sucesso ou navegue para outra tela
    } else {
      final responseData = json.decode(response.body);
      print('Erro de login: ${responseData['message']}');
      // Exiba uma mensagem de erro
    }
  } catch (error) {
    print('Erro ao conectar ao servidor: $error');
    // Exiba uma mensagem de erro de conexão
  }
}
