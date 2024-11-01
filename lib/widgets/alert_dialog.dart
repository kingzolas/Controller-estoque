import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocityestoque/models/auth_provider.dart';
import 'package:velocityestoque/models/member_model.dart';
import 'package:velocityestoque/models/product_model.dart';
import 'package:velocityestoque/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../baseConect.dart';

class AlertDialogs extends StatefulWidget {
  final Product productModel;

  const AlertDialogs({
    super.key,
    required this.productModel,
  });

  @override
  State<AlertDialogs> createState() => _AlertDialogsState();
}

class _AlertDialogsState extends State<AlertDialogs> {
  final TextEditingController _quantidadeController = TextEditingController();
  String tipoMovimentacao = 'ENTRADA';
  MemberModel? selectedMember; // Armazena o membro selecionado
  List<MemberModel> members = []; // Armazena os membros recebidos da API

  @override
  void initState() {
    super.initState();
    fetchMembers(); // Busca os membros ao iniciar o widget
  }

  // Função para buscar membros da API
  Future<void> fetchMembers() async {
    try {
      final response =
          await http.get(Uri.parse('${Config.apiUrl}/api/members'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          members = data.map((json) => MemberModel.fromJson(json)).toList();
        });
      } else {
        throw Exception('Falha ao carregar membros');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

  void realizarMovimentacao() async {
    final int quantidade = int.tryParse(_quantidadeController.text) ?? 0;

    if (quantidade > 0 && selectedMember != null) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.userId; // Acesse o userId

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Usuário não disponível. Por favor, faça login novamente.'),
          ));
          return;
        }

        // Preparar o corpo da requisição
        final body = {
          'quantity': quantidade,
          'tipoMovimentacao': tipoMovimentacao,
          'membro': selectedMember!.id,
          'usuario': userId, // Adiciona o ID do usuário
          'produtoName': widget.productModel.name
        };

        // Imprimir o corpo da requisição para depuração
        print('Corpo da requisição para movimentação: $body');

        // Enviar requisição para o servidor
        final response = await http.put(
          Uri.parse('${Config.apiUrl}/api/products/${widget.productModel.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer ${authProvider.token}', // Se você estiver usando um token
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          // Registre a movimentação no histórico
          final historicoBody = {
            'produto': widget.productModel.id,
            'tipoMovimentacao': tipoMovimentacao,
            'quantidade': quantidade,
            'usuario': userId,
            'membro': selectedMember!.id, // Adiciona o ID do membro
            'produtoName': widget.productModel.name
          };

          // Imprimir o corpo da requisição para o histórico
          print('Corpo da requisição para histórico: $historicoBody');

          await http.post(
            Uri.parse('${Config.apiUrl}/api/historico-movimentacao'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'Bearer ${authProvider.token}', // Adicione o token na requisição
            },
            body: jsonEncode(historicoBody),
          );

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Movimentação de $quantidade unidades como $tipoMovimentacao realizada com sucesso para ${selectedMember!.name}!'),
          ));
          Navigator.pop(context); // Fechar o diálogo após confirmar
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao realizar movimentação: ${response.body}'),
          ));
        }
      } catch (error) {
        print('Erro: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao realizar movimentação: $error'),
        ));
      }
    } else if (selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor, selecione um membro.'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor, insira uma quantidade válida.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return AlertDialog(
      title: Text(
        'Movimentar Estoque - ${widget.productModel.name}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Container(
        height: 240,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo de quantidade
            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Dropdown para tipo de movimentação
            DropdownButtonFormField<String>(
              value: tipoMovimentacao,
              items: [
                DropdownMenuItem(
                    value: 'ENTRADA', child: Text('Entrada de Estoque')),
                DropdownMenuItem(
                    value: 'SAIDA', child: Text('Retirada de Estoque')),
              ],
              onChanged: (value) {
                setState(() {
                  tipoMovimentacao = value ?? 'ENTRADA';
                });
              },
              decoration: InputDecoration(
                labelText: 'Tipo de Movimentação',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Dropdown para seleção de membro
            DropdownButtonFormField<MemberModel>(
              value: selectedMember,
              items: members.map((member) {
                return DropdownMenuItem<MemberModel>(
                  value: member,
                  child: Text(member.name),
                );
              }).toList(),
              onChanged: (MemberModel? value) {
                setState(() {
                  selectedMember = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Selecione um Membro',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Fechar o diálogo sem confirmar
          },
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: realizarMovimentacao,
          child: Text(
            'Confirmar',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
      ],
    );
  }
}
