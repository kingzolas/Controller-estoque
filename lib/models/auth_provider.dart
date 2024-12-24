import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _userName;
  String? _email;
  String? _token; // Adicione esta linha para armazenar o token
  String? _oficcer;
  bool get isAuthenticated => _userId != null;

  void login(String userId, String userName, String email, String token,
      String oficcer) {
    _userId = userId;
    _userName = userName;
    _email = email;
    _token = token; // Armazena o token durante o login
    _oficcer = oficcer;
    notifyListeners(); // Notifica os ouvintes sobre as mudanças
  }

  String? get userId => _userId;
  String? get userName => _userName;
  String? get email => _email;
  String? get token => _token; // Adicione o getter para o token
  String? get oficcer => _oficcer;

  void logout() {
    _userId = null;
    _userName = null;
    _email = null;
    _token = null; // Limpa o token durante o logout
    _oficcer = null;
    notifyListeners();
  }
}
