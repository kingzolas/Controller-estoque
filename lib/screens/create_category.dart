import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../baseConect.dart';

class CreateCategoryPage extends StatefulWidget {
  @override
  _CreateCategoryPageState createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _createCategory() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(
          '${Config.apiUrl}/api/categories'); // Substitua pelo seu endpoint real
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'description': _descriptionController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Categoria criada com sucesso
        _showSuccessDialog(); // Exibe o popup de sucesso
      } else {
        // Tratar erro de criação
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Falha ao criar a categoria: ${response.body}')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sucesso'),
          content: Text('Categoria criada com sucesso!'),
          backgroundColor: Colors.green, // Cor de fundo verde
          titleTextStyle:
              TextStyle(color: Colors.white), // Cor do texto do título
          contentTextStyle:
              TextStyle(color: Colors.white), // Cor do texto do conteúdo
          actions: [
            TextButton(
              child: Text('Fechar', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o popup
                // Aqui, se você quiser, pode limpar os campos ou fazer outra ação
                _nameController.clear();
                _descriptionController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Categoria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome da Categoria'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da categoria.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição da categoria.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createCategory,
                child: Text('Criar Categoria'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
