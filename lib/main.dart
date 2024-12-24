import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/dashboard.dart';
import 'package:velocityestoque/screens/login_page.dart';
import 'package:velocityestoque/models/auth_provider.dart';
import 'package:velocityestoque/models/user_provider.dart';
import 'package:velocityestoque/websocket_service.dart'; // Importando o serviço WebSocket
import 'provider/product_Provider.dart';

void main() {
  debugPaintSizeEnabled = false;

  // Inicializa o WebSocketService
  final webSocketService = WebSocketService(url: 'ws://${Socket.apiUrl}');
  // Adiciona eventos
  webSocketService.on('userJoined', (data) {
    print("Usuário entrou: $data");
  });

  webSocketService.on('messageReceived', (data) {
    print("Mensagem recebida: $data");
  });

  // Envia uma mensagem
  webSocketService
      .sendMessage(json.encode({'event': 'sayHello', 'data': 'Olá!'}));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        Provider<WebSocketService>.value(
            value: webSocketService), // Adiciona ao Provider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
          },
        ),
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: LoginPage(),
      ),
    );
  }
}
