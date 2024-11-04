import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final WebSocketChannel channel;

  WebSocketService(String url)
      : channel = WebSocketChannel.connect(Uri.parse(url));

  // Método para enviar mensagens
  void sendMessage(String message) {
    channel.sink.add(jsonEncode({'message': message}));
  }

  // Stream para escutar mensagens
  Stream<dynamic> get messages => channel.stream;

  // Método para fechar a conexão
  void dispose() {
    channel.sink.close();
  }

  void close() {}
}
