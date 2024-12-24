import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:velocityestoque/models/auth_provider.dart';
import 'package:velocityestoque/models/marcas_model.dart';

import '../baseConect.dart';
import '../popups/popup_createProduct.dart';
import '../services/products_services.dart';

class ProductRegistrationPage extends StatefulWidget {
  @override
  _ProductRegistrationPageState createState() =>
      _ProductRegistrationPageState();
}

class _ProductRegistrationPageState extends State<ProductRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para os campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedMarcaId;
  String? _selectedCategoryId; // Armazena o ID da categoria selecionada
  String? _selectedUnit;
  List<MarcasModel> _marcas = []; // Mapeia marcas
  List<Map<String, dynamic>> _categories = []; // Mapeia categorias
  final List<String> _units = ['Unidade', 'Kg', 'Litros', 'Caixas'];
  final ProductServices _productServices =
      ProductServices('ws://192.168.99.239:3000');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carrega categorias e marcas
  Future<void> _loadData() async {
    _categories = await _productServices.fetchCategories();
    _marcas = await _productServices.fetchMarcas();
    setState(() {});
  }

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
            child: PopupCreateproduct(
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
    Future.delayed(Duration(seconds: 5), () {
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

  // Função para enviar o produto cadastrado para a API
  Future<void> _submitProduct(
      String name,
      String categoryId,
      String description,
      String unit,
      String userId,
      String marca,
      int totalQuantity) async {
    final url = '${Config.apiUrl}/api/products';
    final Map<String, dynamic> productData = {
      'name': name,
      // 'quantity': quantity,
      'category': categoryId, // Passando o ID da categoria
      'description': description,
      'unit': unit,
      'marca': marca,
      'usuarioId': userId,
      'totalQuantity': totalQuantity
    };

    // Adicione esta linha para ver o que está sendo enviado ao servidor
    print('Enviando dados para o servidor: ${jsonEncode(productData)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        print(response.body);
        showCustomPopup(context, _nameController.text);
        // Produto cadastrado com sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto cadastrado com sucesso!')),
        );
        // Limpar os campos
        _nameController.clear();
        _quantityController.clear();
        _descriptionController.clear();

        setState(() {
          _selectedMarcaId = null;
          _selectedCategoryId = null;
          _selectedUnit = null;
        });
      } else {
        throw Exception('Falha ao cadastrar o produto');
      }
    } catch (error) {
      print('Erro: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar o produto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Cadastro de Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nome do Produto
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Produto',
                  prefixIcon:
                      Icon(Icons.article), // Ícone para o nome do produto
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do produto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Quantidade
              // TextFormField(
              //   controller: _quantityController,
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(
              //     labelText: 'Quantidade',
              //     prefixIcon: Icon(Icons.add), // Ícone para quantidade
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Por favor, insira a quantidade';
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: 16),

              // Categoria (Dropdown carregando as categorias da API)
              DropdownButtonFormField<dynamic>(
                value: _selectedMarcaId,
                items: _marcas.map((marca) {
                  return DropdownMenuItem(
                    value: marca.id, // Usando ID da categoria
                    child: Text(marca.name),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Marca do Produto',
                  prefixIcon: Icon(Icons.sell), // Ícone para categoria
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedMarcaId = value; // Armazena o ID selecionado
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma Marca';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
// botão de marca
              DropdownButtonFormField<dynamic>(
                value: _selectedCategoryId,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['id'], // Usando ID da categoria
                    child: Text(category['name']),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Categoria do Produto',
                  prefixIcon: Icon(Icons.category), // Ícone para categoria
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value; // Armazena o ID selecionado
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma categoria';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description), // Ícone para descrição
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Unidade de Medida
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                items: _units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Unidade de Medida',
                  prefixIcon: Icon(Icons.straighten), // Ícone para unidade
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione a unidade de medida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Botão para salvar o produto
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final String name = _nameController.text;
                    // final int quantity = int.parse(_quantityController.text);
                    final String categoryId = _selectedCategoryId ?? '';
                    final String description = _descriptionController.text;
                    final String unit = _selectedUnit ?? '';
                    final String userId = authProvider.userId ?? '';
                    final String marca = _selectedMarcaId ?? '';
                    final int totalQuantity = 0;

                    // Submeter produto para API
                    _submitProduct(name, categoryId, description, unit, userId,
                        marca, totalQuantity);
                  }
                },
                child: Text('Cadastrar Produto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
