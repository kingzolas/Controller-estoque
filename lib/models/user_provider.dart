import 'package:flutter/material.dart';
import 'user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void login(String id, String email, String name) {
    _user = UserModel(id: id, email: email, name: name);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
