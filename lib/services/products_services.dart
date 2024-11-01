import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/models/product_model.dart';

import '../models/movimentacao_model.dart';

class ProductServices {
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
        // Mapeia os dados JSON para uma lista de objetos Product usando fromJson
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
  // Função para buscar o histórico de movimentações de um membro específico
  Future<List<MovimentacaoModel>> fetchMemberHistory(String memberId) async {
    final url = '${Config.apiUrl}/api//historico-movimentacoes/$memberId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> data = jsonDecode(response.body);
        // Mapeia os dados JSON diretamente para uma lista de MovimentacaoModel usando fromJson
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
  // Função para enviar o produto cadastrado para a API
  Future<void> submitProduct(String name, int quantity, String categoryId,
      String description, String unit, String userId, String marca) async {
    final url = '${Config.apiUrl}/api/products';
    final Map<String, dynamic> productData = {
      'name': name,
      'quantity': quantity,
      'category': categoryId, // Passando o ID da categoria
      'description': description,
      'unit': unit,
      'marca': marca,
      'usuarioId': userId
    };
  }

  // Método para atualizar quantidade de produtos novos
  Future<void> updateNewProductQuantity(
      String productId, int quantity, String userId) async {
    final url = '${Config.apiUrl}/api/products/$productId/novo';

    try {
      print("Enviando quantidade: $quantity");
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'conditionQuantities': {'new': quantity}, // Atualização aqui
          'tipoMovimentacao': 'ENTRADA',
          'usuario': userId
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

  // Método para atualizar quantidade de produtos usados
  Future<void> updateUsedProductQuantity(
      String productId, int quantity, String userId) async {
    final url = '${Config.apiUrl}/api/products/$productId/usado';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'conditionQuantities': {'used': quantity},
          'tipoMovimentacao': 'ENTRADA',
          'usuario': userId
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
  Future<void> updateDamagedProductQuantity(
      String productId, int quantity, String userId) async {
    final url = '${Config.apiUrl}/api/products/$productId/danificado';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'conditionQuantities': {'damaged': quantity}, // Atualização aqui
          'tipoMovimentacao': 'ENTRADA',
          'usuario': userId
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
}
