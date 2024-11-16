import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:velocityestoque/dashboard.dart';
import 'package:velocityestoque/screens/login_page.dart';
import 'package:velocityestoque/models/auth_provider.dart';
import 'package:velocityestoque/models/user_provider.dart';
// import 'package:velocityestoque/services/websocket_service.dart';
import 'package:velocityestoque/websocket_service.dart';

import 'provider/product_Provider.dart'; // Importando o serviço

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
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
          PointerDeviceKind.unknown
        },
      ),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    ));
  }
}

class MyWebSocketApp extends StatefulWidget {
  @override
  _MyWebSocketAppState createState() => _MyWebSocketAppState();
}

class _MyWebSocketAppState extends State<MyWebSocketApp> {
  late WebSocketService webSocketService;

  @override
  void initState() {
    super.initState();
    webSocketService = WebSocketService('ws://192.168.99.239:3000');
    webSocketService.messages.listen((message) {
      // Tratar a mensagem recebida
      print('Mensagem recebida: $message');
    });
  }

  @override
  void dispose() {
    webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(); // Retorna o seu aplicativo principal
  }
}
