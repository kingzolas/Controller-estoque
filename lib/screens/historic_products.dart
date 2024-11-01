import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:velocityestoque/baseConect.dart';

class HistoricProducts extends StatefulWidget {
  const HistoricProducts({super.key});

  @override
  State<HistoricProducts> createState() => _HistoricProductsState();
}

class _HistoricProductsState extends State<HistoricProducts> {
  List<dynamic> _historico = [];
  List<String> _produtos = [];
  List<String> _usuarios = [];
  List<String> _membros = [];
  String? _selectedProduto;
  String? _selectedUsuario;
  String? _selectedMembro;

  Future<void> fetchHistorico() async {
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/api/historico-movimentacoes'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _historico = jsonDecode(response.body);
        _produtos = _historico
            .map((mov) => mov['produtoData']?['name'])
            .whereType<String>()
            .toSet()
            .toList();
        _usuarios = _historico
            .map((mov) => mov['usuarioData']?['name'])
            .whereType<String>()
            .toSet()
            .toList();
        _membros = _historico
            .map((mov) => mov['membroData']?['name'])
            .whereType<String>()
            .toSet()
            .toList();
      });
    } else {
      throw Exception('Erro ao carregar histórico de movimentações');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistorico();
  }

  String getTipoMovimentacao(Map<String, dynamic> movimentacao) {
    if (movimentacao['membroData'] == null) {
      return 'CADASTRO';
    } else if (movimentacao['tipoMovimentacao'] == 'ENTRADA') {
      return 'ENTRADA';
    } else {
      return 'SAIDA';
    }
  }

  Color getMovimentacaoColor(String tipo) {
    switch (tipo) {
      case 'ENTRADA':
        return Colors.green[100]!;
      case 'SAIDA':
        return Colors.red[100]!;
      case 'CADASTRO':
        return Colors.blue[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  IconData getMovimentacaoIcon(String tipo) {
    switch (tipo) {
      case 'ENTRADA':
        return Icons.arrow_downward;
      case 'SAIDA':
        return Icons.arrow_upward;
      case 'CADASTRO':
        return Icons.add_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  String formatarData(String dataISO) {
    DateTime data = DateTime.parse(dataISO);
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
  }

  void clearFilters() {
    setState(() {
      _selectedProduto = null;
      _selectedUsuario = null;
      _selectedMembro = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Movimentações'),
        actions: [
          if (_selectedProduto != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Chip(
                label: Text('Produto: $_selectedProduto'),
                onDeleted: () {
                  setState(() {
                    _selectedProduto = null;
                  });
                },
              ),
            ),
          if (_selectedUsuario != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Chip(
                label: Text('Usuário: $_selectedUsuario'),
                onDeleted: () {
                  setState(() {
                    _selectedUsuario = null;
                  });
                },
              ),
            ),
          if (_selectedMembro != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Chip(
                label: Text('Membro: $_selectedMembro'),
                onDeleted: () {
                  setState(() {
                    _selectedMembro = null;
                  });
                },
              ),
            ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearFilters,
            tooltip: 'Remover Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: const Text('Produto'),
                  value: _selectedProduto,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedProduto = newValue;
                    });
                  },
                  items: _produtos.map((produto) {
                    return DropdownMenuItem(
                      value: produto,
                      child: Text(produto),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  hint: const Text('Usuário'),
                  value: _selectedUsuario,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUsuario = newValue;
                    });
                  },
                  items: _usuarios.map((usuario) {
                    return DropdownMenuItem(
                      value: usuario,
                      child: Text(usuario),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  hint: const Text('Membro'),
                  value: _selectedMembro,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMembro = newValue;
                    });
                  },
                  items: _membros.map((membro) {
                    return DropdownMenuItem(
                      value: membro,
                      child: Text(membro),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _historico.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _historico.length,
                    itemBuilder: (context, index) {
                      final movimentacao = _historico[index];

                      if ((_selectedProduto != null &&
                              movimentacao['produtoData']
                                      ?['name'] !=
                                  _selectedProduto) ||
                          (_selectedUsuario != null &&
                              movimentacao['usuarioData']?['name'] !=
                                  _selectedUsuario) ||
                          (_selectedMembro != null &&
                              movimentacao['membroData']?['name'] !=
                                  _selectedMembro)) {
                        return const SizedBox.shrink();
                      }

                      final tipoMovimentacao =
                          getTipoMovimentacao(movimentacao);
                      final produtoNome = movimentacao['produtoData']
                              ?['name'] ??
                          'Produto desconhecido';
                      final usuarioNome = movimentacao['usuarioData']
                              ?['name'] ??
                          'Usuário desconhecido';
                      final dataMovimentacao =
                          formatarData(movimentacao['dataMovimentacao']);

                      return Card(
                        color: getMovimentacaoColor(tipoMovimentacao),
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: Icon(
                            getMovimentacaoIcon(tipoMovimentacao),
                            color: tipoMovimentacao == 'ENTRADA'
                                ? Colors.green
                                : tipoMovimentacao == 'SAIDA'
                                    ? Colors.red
                                    : Colors.blue,
                          ),
                          title: Text(produtoNome),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tipo: $tipoMovimentacao'),
                              Text('Quantidade: ${movimentacao['quantidade']}'),
                              Text('Usuário: $usuarioNome'),
                              if (tipoMovimentacao == 'CADASTRO')
                                Text('Cadastro de Produto'),
                              if (tipoMovimentacao != 'CADASTRO' &&
                                  movimentacao['membroData'] != null)
                                Text(
                                    'Membro: ${movimentacao['membroData']['name']}'),
                              Text('Data: $dataMovimentacao'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
