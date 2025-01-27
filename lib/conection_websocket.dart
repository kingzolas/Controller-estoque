import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel channel;
  bool _isConnected = false;
  Timer? _pingTimer;

  // Função para inicializar a conexão WebSocket
  void connectWebSocket(String apiUrl) {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://$apiUrl'),
    );

    // Escutando as mensagens do WebSocket
    channel.stream.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onDone: _onWebSocketDisconnected,
      onError: _onWebSocketError,
    );

    _isConnected = true;
    _startPing();
  }

  // Função para escutar mensagens do WebSocket
  void _handleWebSocketMessage(String message) {
    print("Mensagem recebida: $message");
    // Aqui você pode processar as mensagens que chegam do WebSocket
  }

  // Função para enviar o ping periodicamente
  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        try {
          final pingMessage = jsonEncode(
              {'action': 'ping'}); // Mensagem de ping em formato JSON
          channel.sink.add(pingMessage);
          print('Ping enviado');
        } catch (e) {
          print('Erro ao enviar ping: $e');
          _onWebSocketDisconnected();
        }
      } else {
        timer.cancel();
      }
    });
  }

  // Função chamada quando o WebSocket é desconectado
  void _onWebSocketDisconnected() {
    _isConnected = false;
    _pingTimer?.cancel();
    print('WebSocket desconectado');
  }

  // Função chamada quando há erro no WebSocket
  void _onWebSocketError(error) {
    _isConnected = false;
    print('Erro no WebSocket: $error');
  }

  // Função para parar a escuta e fechar a conexão
  void disconnect() {
    _isConnected = false;
    channel.sink.close();
  }

  // Função para começar a escutar as atualizações
  void startListeningForUpdates(
      Function(String, Map<String, dynamic>) listener) {
    channel.stream.listen((message) {
      final data =
          jsonDecode(message); // Supondo que as mensagens sejam em JSON
      final memberId = data['memberId'];
      final updatedData = data['updatedData'];
      listener(memberId, updatedData);
    });
  }

  // Função para escutar atualizações de membros com dados parciais
  void listenForMemberUpdates(Function(String, Map<String, dynamic>) onUpdate) {
    channel.stream.listen((message) {
      try {
        final data = jsonDecode(message);

        // Verifique se o evento é 'user_updated' e se os dados não são nulos
        if (data['event'] == 'user_updated' && data['data'] != null) {
          final String memberId =
              data['data']['id'] ?? ''; // Atribui valor default se for null
          final Map<String, dynamic> updatedData = data['data'];

          // Chama o callback passando o id e os dados atualizados
          onUpdate(memberId, updatedData);
        }
      } catch (e) {
        print('Erro ao processar atualização de membro: $e');
      }
    });
  }
}
