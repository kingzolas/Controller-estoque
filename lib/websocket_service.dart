import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  late WebSocketChannel _channel;
  final Map<String, List<Function>> _eventListeners = {};
  late String _url;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectInterval = Duration(seconds: 5);

  // Construtor privado para o Singleton
  WebSocketService._internal();

  // Fábrica para acessar a instância única
  factory WebSocketService({required String url}) {
    _instance._url = url;
    if (!_instance._isConnected) {
      _instance.connect();
    }
    return _instance;
  }

  // Inicializa a conexão
  void connect() {
    try {
      print("Conectando ao WebSocket...");
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      _isConnected = true;
      _reconnectAttempts = 0;

      _channel.stream.listen(
        (message) {
          try {
            final data = json.decode(message);
            _handleEvent(data); // Trata o evento recebido
          } catch (e) {
            print("Erro ao processar mensagem WebSocket: $e");
          }
        },
        onDone: () {
          print("Conexão encerrada. Tentando reconectar...");
          _isConnected = false;
          _attemptReconnect();
        },
        onError: (error) {
          print("Erro no WebSocket: $error");
          _isConnected = false;
          _attemptReconnect();
        },
      );
    } catch (e) {
      print("Erro ao conectar ao WebSocket: $e");
      _attemptReconnect();
    }
  }

  // Envia mensagens
  void sendMessage(String message) {
    if (_isConnected) {
      _channel.sink.add(message);
    } else {
      print("Conexão WebSocket não está aberta.");
    }
  }

  // Fecha a conexão
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    _isConnected = false;
    _channel.sink.close(status.normalClosure);
  }

  // Registra um listener para um evento específico
  void on(String event, Function(Map<String, dynamic>) callback) {
    if (!_eventListeners.containsKey(event)) {
      _eventListeners[event] = [];
    }
    _eventListeners[event]!.add(callback);
  }

  // Remove todos os listeners de um evento
  void off(String event) {
    _eventListeners.remove(event);
  }

  // Processa eventos recebidos e chama os listeners registrados
  void _handleEvent(Map<String, dynamic> data) {
    final event = data['event'];
    if (_eventListeners.containsKey(event)) {
      for (final callback in _eventListeners[event]!) {
        callback(data['data']);
      }
    }
  }

  // Tenta restabelecer a conexão
  void _attemptReconnect() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectTimer = Timer(_reconnectInterval, () {
        _reconnectAttempts++;
        print("Tentando reconectar... Tentativa $_reconnectAttempts");
        connect();
      });
    } else {
      print(
          "Máximo de tentativas de reconexão alcançado. Reconexão cancelada.");
    }
  }
}
