import 'package:flutter/material.dart';
import 'package:velocityestoque/services/products_services.dart';

class CreateMarcas extends StatefulWidget {
  const CreateMarcas({super.key});

  @override
  State<CreateMarcas> createState() => _CreateMarcasState();
}

class _CreateMarcasState extends State<CreateMarcas> {
  final ProductServices _productServices =
      ProductServices('ws://192.168.99.239:3000');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fabricanteController = TextEditingController();

  void _createNewMarca() async {
    final name = _nameController.text;
    final fabricante = _fabricanteController.text;

    if (name.isNotEmpty && fabricante.isNotEmpty) {
      await _productServices.createMarca(name, fabricante);
      _nameController.clear();
      _fabricanteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marca criada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Marca'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome da Marca'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _fabricanteController,
              decoration: InputDecoration(labelText: 'Fabricante'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createNewMarca,
              child: Text('Criar Marca'),
            ),
          ],
        ),
      ),
    );
  }
}
