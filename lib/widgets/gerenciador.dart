import 'package:flutter/material.dart';
import 'package:velocityestoque/widgets/dashboardScreen.dart';
import 'package:velocityestoque/widgets/productRegistrationPage.dart';
// import 'package:velocityestoque/productRegistrationPage.dart';
import 'package:velocityestoque/screens/create_category.dart';
import 'package:velocityestoque/screens/create_marcas.dart';
import 'package:velocityestoque/screens/create_members.dart';
import 'package:velocityestoque/screens/historic_products.dart';

import 'package:velocityestoque/screens/produtos.dart';

// import 'screens/productRegistrationPage.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dashboardscreen();
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

class Marcas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CreateMarcas();
  }
}
