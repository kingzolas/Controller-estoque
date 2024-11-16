import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/models/product_model.dart';
import 'package:velocityestoque/models/movimentacao_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class ProductServices {
  final WebSocketChannel channel;

  ProductServices(String socketUrl)
      : channel = IOWebSocketChannel.connect(socketUrl);

  // Função para buscar as categorias
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final url = '${Config.apiUrl}/api/categories';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((category) {
          return {'id': category['_id'], 'name': category['name']};
        }).toList();
      } else {
        throw Exception('Falha ao carregar categorias');
      }
    } catch (error) {
      print('Erro: $error');
      return [];
    }
  }

  // Função para buscar as marcas
  Future<List<Map<String, dynamic>>> fetchMarcas() async {
    final url = '${Config.apiUrl}/api/marcas';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((marca) {
          return {
            'id': marca['_id'],
            'name': marca['name'],
            'fabricante': marca['fabricante']
          };
        }).toList();
      } else {
        throw Exception('Falha ao carregar marcas');
      }
    } catch (error) {
      print('Erro: $error');
      return [];
    }
  }

  Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('${Config.apiUrl}/api/products/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> productData = jsonDecode(response.body);
        return productData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar produtos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
      return [];
    }
  }

  // Função para buscar o histórico de movimentações de um membro específico
  Future<List<MovimentacaoModel>> fetchMemberHistory(String memberId) async {
    final url = '${Config.apiUrl}/api/historico-movimentacoes/$memberId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // print(response.body);
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MovimentacaoModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar histórico de movimentações');
      }
    } catch (error) {
      print('Erro: $error');
      return [];
    }
  }

  // Função para submeter o produto
  Future<void> submitProduct(String name, int quantity, String categoryId,
      String description, String unit, String userId, String marca) async {
    final url = '${Config.apiUrl}/api/products';
    final Map<String, dynamic> productData = {
      'name': name,
      'quantity': quantity,
      'category': categoryId,
      'description': description,
      'unit': unit,
      'marca': marca,
      'usuarioId': userId
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(productData),
      );
      if (response.statusCode != 201) {
        throw Exception('Erro ao cadastrar produto: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

// Método para atualizar quantidade de produtos novos
  Future<void> updateNewProductQuantity(String productId, int quantity,
      String userId, String movementacao, String marca,
      {String? membroId}) async {
    final url = '${Config.apiUrl}/api/products/$productId/novo';

    try {
      print("Enviando quantidade: $quantity");
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'conditionQuantities': {'new': quantity},
          'tipoMovimentacao': movementacao,
          'usuario': userId,
          'membro': membroId ??
              null, // Usando membroId, se não for fornecido, será uma string vazia
          'marca': marca,
          'statusProduto': 'Novo',
        }),
      );
      if (response.statusCode == 200) {
        print('Quantidade de produtos novos atualizada com sucesso.');
      } else {
        throw Exception(
            'Erro ao atualizar produto novo: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

  Future<void> createMarca(String name, String fabricante) async {
    final url = '${Config.apiUrl}/api/marca';
    final Map<String, dynamic> marcaData = {
      'name': name,
      'fabricante': fabricante
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(marcaData),
      );
      if (response.statusCode != 201) {
        throw Exception('Erro ao cadastrar marca: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro $error');
    }
  }

// Método para atualizar quantidade de produtos usados
  Future<void> updateUsedProductQuantity(String productId, int quantity,
      String userId, String movementacao, String marca,
      {String? membroId}) async {
    final url = '${Config.apiUrl}/api/products/$productId/usado';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'conditionQuantities': {'used': quantity},
          'tipoMovimentacao': movementacao,
          'usuario': userId,
          'membro': membroId ?? null,
          'marca':
              marca, // Usando membroId, se não for fornecido, será uma string vazia
          'statusProduto': 'Usado',
        }),
      );
      if (response.statusCode == 200) {
        print('Quantidade de produtos usados atualizada com sucesso.');
      } else {
        throw Exception(
            'Erro ao atualizar produto usado: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

// Método para atualizar quantidade de produtos danificados
  Future<void> updateDamagedProductQuantity(String productId, int quantity,
      String userId, String movementacao, String marca,
      {String? membroId}) async {
    final url = '${Config.apiUrl}/api/products/$productId/danificado';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'conditionQuantities': {'damaged': quantity},
          'tipoMovimentacao': movementacao,
          'usuario': userId,
          'membro': membroId ??
              null, // Usando membroId, se não for fornecido, será uma string vazia
          'marca': marca,
          'statusProduto': 'Danificado',
        }),
      );
      if (response.statusCode == 200) {
        print('Quantidade de produtos danificados atualizada com sucesso.');
      } else {
        throw Exception(
            'Erro ao atualizar produto danificado: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

  // Método para registrar a devolução de um produto
  Future<void> returnProduct(int quantity, String userId, String reason,
      String membroId, String movimentaId, String status) async {
    final url = '${Config.apiUrl}/api/movimentacoes/$movimentaId/devolucao';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // movimentaId: movimentaId,
          // 'produto._id': productId,
          'quantidadeDevolvida': quantity,
          'usuario': userId,
          'membro': membroId,
          'motivoDevolucao': reason,
          'statusProduto': status
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Produto devolvido com sucesso.');
      } else {
        throw Exception('Erro ao registrar devolução: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

// Método para escutar mensagens do WebSocket e atualizar a interface do usuário em tempo real
  void listenToMessages(Function(Map<String, dynamic> update) onUpdate) {
    channel.stream.listen((message) {
      // Decodifica a mensagem JSON recebida
      final decodedMessage = jsonDecode(message);
      // Chama a função passada como parâmetro para atualizar os dados
      onUpdate(decodedMessage);
    }, onError: (error) {
      print('Erro no WebSocket: $error');
    }, onDone: () {
      print('WebSocket desconectado');
    });
  }

  // Método para fechar o WebSocket
  void dispose() {
    channel.sink.close();
  }
}
