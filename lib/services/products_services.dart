import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/models/historicos_model.dart';
import 'package:velocityestoque/models/marcas_model.dart';
import 'package:velocityestoque/models/product_model.dart';
import 'package:velocityestoque/models/movimentacao_model.dart';
import 'package:velocityestoque/models/user_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http_parser/http_parser.dart';
import '../models/member_model.dart';
import '../models/users_model.dart';

class ProductServices {
  final WebSocketChannel channel;
  Timer? _pingTimer;
  static const int _pingInterval =
      30; // Intervalo em segundos para enviar o "ping"

  ProductServices(String socketUrl)
      : channel = WebSocketChannel.connect(Uri.parse(socketUrl)) {
    // Inicia o "ping-pong" assim que a conexão for estabelecida
    _startPingPong();
  }

  // Função para iniciar o "ping-pong"
  void _startPingPong() {
    _pingTimer = Timer.periodic(Duration(seconds: _pingInterval), (timer) {
      _sendPing();
    });
  }

  // Função para enviar o "ping"
  void _sendPing() {
    if (channel != null && channel.sink != null) {
      channel.sink
          .add(jsonEncode({'type': 'ping'})); // Envia o ping para o servidor
      print('Ping enviado...');
    }
  }

  // Função para escutar as respostas "pong"
  void listenForPong() {
    channel.stream.listen((message) {
      try {
        final data = jsonDecode(message);

        if (data['type'] == 'pong') {
          print('Pong recebido');
        }
      } catch (e) {
        print('Erro ao processar resposta do servidor: $e');
      }
    });
  }

  // Função para parar o "ping-pong" quando não for mais necessário
  void stopPingPong() {
    _pingTimer?.cancel();
    print('Ping-pong interrompido.');
  }

  // Método para escutar as mensagens do WebSocket
  Stream<dynamic> get productStream => channel.stream;
  // Stream para escutar mensagens do WebSocket
  Stream<dynamic> get memberStream => channel.stream;

  // Função para enviar mensagens ao servidor via WebSocket
  void sendMessage(Map<String, dynamic> message) {
    channel.sink.add(jsonEncode(message));
  }

  // Função para escutar atualizações de membros
// Função para escutar atualizações de membros com dados parciais
  void listenForMemberUpdates(Function(String, Map<String, dynamic>) onUpdate) {
    memberStream.listen((message) {
      try {
        final data = jsonDecode(message);

        if (data['event'] == 'user_updated' && data['data'] != null) {
          final String memberId =
              data['data']['id'] ?? ''; // Atribui valor default se for null
          final Map<String, dynamic> updatedData = data['data'];

          onUpdate(memberId,
              updatedData); // Passa id e dados atualizados para o callback
        }
      } catch (e) {
        print('Erro ao processar atualização de membro: $e');
      }
    });
  }

  void listenForProductUpdates(Function(Product) onUpdate) {
    productStream.listen((message) {
      try {
        final data = jsonDecode(message);

        // Verificar os dados antes de convertê-los para Product
        print('Dados recebidos: $data');

        if (data['event'] == 'productUpdated' && data['data'] != null) {
          Product updatedProduct = Product.fromJson(data['data']);
          onUpdate(
              updatedProduct); // Passa o produto atualizado para o callback
        }
      } catch (e) {
        print('Erro ao processar atualização de produto: $e');
      }
    });
  }

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
  Future<List<MarcasModel>> fetchMarcas() async {
    final url = '${Config.apiUrl}/api/marcas';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> marcaData = jsonDecode(response.body);
        print('Dados recebidos: $marcaData'); // Log detalhado
        return marcaData
            .map((json) {
              try {
                return MarcasModel.fromJson(json); // Tentar parsear cada item
              } catch (e) {
                print('Erro ao parsear item: $json\nErro: $e');
                return null; // Caso o dado não seja válido
              }
            })
            .whereType<MarcasModel>()
            .toList(); // Filtra nulos
      } else {
        print('Erro na requisição: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Erro ao buscar marcas: $error');
      return [];
    }
  }

  Future<List<MemberModel>> fetchMembers() async {
    final url = Uri.parse('${Config.apiUrl}/api/members//');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> memberData = jsonDecode(response.body);
        return memberData.map((json) => MemberModel.fromJson(json)).toList();
      } else {
        throw Exception("Error ao buscar membros: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('${Config.apiUrl}/api/products');
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

  Future<List<HistoricosModel>> fetchHitoricosMovimentacao() async {
    final url = '${Config.apiUrl}/api/historico-movimentacoes';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("deu certoooo $response.body");
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => HistoricosModel.fromJson(json)).toList();
      } else {
        throw Exception("Falha ao carregar historico de movimentações");
      }
    } catch (error) {
      print('Erro: $error');
      return [];
    }
  }

  Future<List<UsersModel>> fetchUsers() async {
    final url = '${Config.apiUrl}/api/users';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Resposta da API: $data');
        final users = data.map((json) => UsersModel.fromJson(json)).toList();
        print('Usuários mapeados: $users');
        return users;
      } else {
        throw Exception('Erro ao buscar usuários: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
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

    // Criar a data no formato desejado, por exemplo, 'dd/MM/yyyy'
    final String dataHoraCriacao = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
        .format(DateTime.now().toUtc().subtract(Duration(hours: 3)));

    // Adicionando a data ao corpo da requisição
    final Map<String, dynamic> marcaData = {
      'name': name,
      'fabricante': fabricante,
      'created_at': dataHoraCriacao, // Aqui você adiciona a data formatada
    };

    try {
      print(marcaData);
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

  Future<Map<String, dynamic>> fetchComparativoMensal() async {
    final url = '${Config.apiUrl}/api/agregacoes/comparativo-mensal';

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
            'Erro ao acessar comparativo mensal: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao acessar comparativo mensal: $error');
      return {}; // Retorna um mapa vazio em caso de erro
    }
  }

  // Método para buscar o resumo dos produtos (quantidade e percentual de cada status)
  Future<Map<String, dynamic>> fetchProductSummary() async {
    final url = Uri.parse('${Config.apiUrl}/api/dashboard/products/summary');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> summaryData = jsonDecode(response.body);
        print(response.body);

        // Acessando corretamente os valores dentro do JSON
        final int total = summaryData['total'] ?? 0;
        final int newCount = summaryData['new']['count'] ?? 0;
        final int usedCount = summaryData['used']['count'] ?? 0;
        final int damagedCount = summaryData['damaged']['count'] ?? 0;
        final String newPercentage = summaryData['new']['percent'] ?? 0;
        final String damagedPercentage = summaryData['damaged']['percent'] ?? 0;
        final String usedPercentage = summaryData['used']['percent'] ?? 0;
        return {
          'new': {'count': newCount, 'percent': newPercentage},
          'used': {'count': usedCount, 'percent': usedPercentage},
          'damaged': {'count': damagedCount, 'percent': damagedPercentage},
          'total': total,
        };
      } else {
        throw Exception(
            'Erro ao buscar resumo de produtos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
      return {}; // Retorna um mapa vazio em caso de erro
    }
  }

  // Método para registrar a devolução de um produto
  returnProduct(int quantity, String userId, String reason, String membroId,
      String movimentaId, String status) async {
    final url = '${Config.apiUrl}/api/movimentacoes/$movimentaId/devolucao';

    try {
      http.Response response = await http.post(
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
        return response;
      } else {
        // throw Exception('Erro ao registrar devolução: ${response.statusCode}');
        return response;
      }
    } catch (error) {
      print('Erro: $error');
    }
  }

  Future<void> updateInfoMember(
    String name,
    String office,
    bool status,
    String memberId,
    File? profileImage,
  ) async {
    final url = '${Config.apiUrl}/api/members/$memberId';
    print(url);

    // Cria a requisição multipart
    final request = http.MultipartRequest('PUT', Uri.parse(url));

    // Adiciona os dados não relacionados à imagem
    request.fields['name'] = name;
    request.fields['office'] = office;
    request.fields['isActive'] = status.toString(); // Converte bool para string

    // Adiciona o arquivo da imagem, se existir
    if (profileImage != null) {
      final mimeType = lookupMimeType(profileImage.path);
      if (mimeType != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }
    }

    try {
      // Envia a requisição
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception(
            'Erro ao atualizar informações do membro: ${response.statusCode}');
      }
      print('Informações do membro atualizadas com sucesso!');
    } catch (error) {
      print("Erro $error");
    }
  }

  Future<void> UpdateInfoProduct(
    String name,
    String descricao,
    String marca,
    String categoria,
    bool status, {
    required String productId,
  }) async {
    final url = '${Config.apiUrl}/api/product/edit/$productId';

    // Criar o map com os dados de forma condicional
    final Map<String, dynamic> productData = {};

    // Adicionar dados apenas se não forem nulos ou vazios
    if (name.isNotEmpty) productData['name'] = name;
    if (categoria.isNotEmpty) productData['category'] = categoria;
    if (descricao.isNotEmpty) productData['description'] = descricao;
    if (marca.isNotEmpty) productData['marca'] = marca;

    // Sempre adicionar isActive, pois não depende de ser vazio
    productData['isActive'] = status;

    print("Antes de remover nulos: $productData");

    // Se o Map não tiver dados, não enviar a requisição
    if (productData.isEmpty) {
      print("Não há dados válidos para enviar.");
      return;
    }

    // Aqui você pode remover manualmente as chaves com valor null
    // Isso é uma garantia extra, mas provavelmente não é necessário já que não adicionamos valores nulos
    productData.removeWhere((key, value) => value == null);

    print("Depois de remover nulos: $productData");

    try {
      // Enviar a requisição com o corpo em JSON
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erro ao atualizar informação do produto: ${response.statusCode}');
      }

      print("Produto atualizado com sucesso!");
    } catch (error) {
      print("Error $error");
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
