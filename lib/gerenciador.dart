import 'package:flutter/material.dart';
import 'package:velocityestoque/productRegistrationPage.dart';
// import 'package:velocityestoque/productRegistrationPage.dart';
import 'package:velocityestoque/screens/create_category.dart';
import 'package:velocityestoque/screens/create_members.dart';
import 'package:velocityestoque/screens/historic_products.dart';

import 'package:velocityestoque/screens/produtos.dart';

// import 'screens/productRegistrationPage.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Center(
        child: Text(
          'Tela em desenvolvimento',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen();
  @override
  Widget build(BuildContext context) {
    return ProductListingPage();
  }
}

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProductRegistrationPage();
  }
}

class Category extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CreateCategoryPage();
  }
}

class Members extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CreateMemberPage();
  }
}

class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HistoricProducts();
  }
}
