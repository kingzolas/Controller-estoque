import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/popups/popup_notificacao_ret.dart';
import 'package:velocityestoque/screens/create_members.dart';
import 'package:velocityestoque/widgets/gerenciador.dart';
import 'package:velocityestoque/models/auth_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'models/historicos_model.dart';
import 'services/products_services.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isConnected = false; // Controle de conexão
  int _selectedIndex = 0; // Índice da tela selecionada
  final ProductServices _productServices =
      ProductServices('ws://${Socket.apiUrl}');
  List<HistoricosModel> _historico = [];

  // Lista de telas
  final List<Widget> _screens = [
    HomeScreen(),
    SettingsScreen(),
    NotificationsScreen(),
    Category(),
    CreateMemberPage(),
    History(),
    Marcas()
  ];

  Future<void> _loadData() async {
    try {
      final historico = await _productServices.fetchHitoricosMovimentacao();
      setState(() {
        _historico = historico;
      });
      // print('Lista de historico dashboard${historico}');
    } catch (error) {}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Atualiza o índice da tela selecionada
    });
  }

  // final WebSocketChannel channel = WebSocketChannel.connect(
  //   Uri.parse('ws://${Socket.apiUrl}'),
  // );

  // Variáveis para gerenciar a conexão WebSocket
  late WebSocketChannel channel;
  // bool _isConnected = false; // Controle de conexão

  // Função para inicializar o WebSocket
  void _connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://${Socket.apiUrl}'),
    );

    // Escuta mensagens do WebSocket
    channel.stream.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onDone: _onWebSocketDisconnected,
      onError: _onWebSocketError,
    );

    setState(() {
      _isConnected = true; // Conectado ao WebSocket
    });

    // Inicia o envio de mensagens de ping
    _startPing();
  }

  Timer? _pingTimer;

  void _startPing() {
    _pingTimer
        ?.cancel(); // Cancela qualquer timer existente antes de criar um novo

    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        try {
          final pingMessage =
              jsonEncode({'action': 'ping'}); // Mensagem como JSON
          channel.sink.add(pingMessage);
          print('Ping enviado');
        } catch (e) {
          print('Erro ao enviar ping: $e');
          _onWebSocketDisconnected();
        }
      } else {
        timer.cancel(); // Cancela o timer se desconectado
      }
    });
  }

  // Função chamada quando o WebSocket é desconectado
  void _onWebSocketDisconnected() {
    setState(() {
      _isConnected = false; // Desconectado do WebSocket
    });

    // Cancela o envio de pings
    _pingTimer?.cancel();

    print('WebSocket desconectado');
  }

  // Função chamada quando há erro no WebSocket
  void _onWebSocketError(error) {
    setState(() {
      _isConnected = false; // Desconectado devido a erro
    });
    print('Erro no WebSocket: $error');
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    // Escuta mensagens do WebSocket
    // channel.stream.listen((message) {
    //   _handleWebSocketMessage(message);
    // });
    _connectWebSocket(); // Conecta ao WebSocket na inicialização
  }

  bool hasNewMovement =
      false; // Variável para controlar se há nova movimentação

  void _handleWebSocketMessage(String message) {
    if (message == 'pong') {
      print('Pong recebido');
      return; // Ignora o processamento adicional
    }

    // Lógica existente para outras mensagens
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final data = jsonDecode(message);

    if (data['event'] == 'productUpdated') {
      final String usuarioMovimento = data['data']['usuario'];
      if (usuarioMovimento != authProvider.userId) {
        _showPopup(data['data']);
      }
    } else if (data['action'] == 'NovaMovimentacao') {
      setState(() {
        hasNewMovement =
            true; // Nova movimentação recebida, bolinha verde visível
      });

      // Adiciona o histórico com a nova movimentação
      final newHistorico = HistoricosModel(
        Marca: data['data']['marca'], // Marca
        StatusItem: data['data']['statusProduto'], // Status do produto
        data: data['data']['dataMovimentacao'], // Data da movimentação
        id: data['data']['id'].toString(), // ID do produto (ObjectId)
        DataMovimentacao: data['data']
            ['dataMovimentacao'], // Data da movimentação
        hora: _extractTimeFromDate(data['data']['dataMovimentacao']), // Hora
        Movimentacao: data['data']['tipoMovimentacao'], // Tipo de movimentação
        Item: data['data']['produto'], // Produto
        Usuario: data['data']['usuario'], // Usuário
        Quantidade: data['data']['quantidade'], // Quantidade
        Membro: data['data']['membro'], // Membro
      );

      setState(() {
        _historico.insert(0, newHistorico); // Adiciona no início da lista
      });
    }
  }

// Função para extrair a hora a partir da data (ISO 8601)
  String _extractTimeFromDate(String date) {
    final DateTime dateTime =
        DateTime.parse(date); // Converte a string para DateTime
    return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}'; // Retorna a hora no formato HH:mm:ss
  }

  void _showPopup(Map<String, dynamic> data) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: PopupNotificacaoRet(
            description: "sda",
            name: '${data['membro']}',
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Remover o popup automaticamente após 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }

  void _ListViewNotifi() {
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
        builder: (context) => ScreenUtilInit(
            designSize: const Size(1920, 1080),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return Stack(
                children: [
                  // Detecta cliques fora do container
                  GestureDetector(
                    onTap: () {
                      // Remove o overlay quando o usuário clicar fora
                      overlayEntry.remove();
                    },
                    behavior: HitTestBehavior
                        .opaque, // Garante que o clique seja detectado em toda a área
                    child: Container(),
                  ),
                  Positioned(
                    top: 50.sp,
                    right: 254.sp,
                    child: Container(
                      width: 396.sp,
                      height: 386.sp,
                      decoration: ShapeDecoration(
                        color: Color(0xCE889BB2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 200.sp,
                          height: 377.sp,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: ListView.builder(
                            itemCount: _historico.length,
                            itemBuilder: (context, index) {
                              return _notfiyText(
                                  horario: _historico[index].hora,
                                  movimentacao: _historico[index].Movimentacao,
                                  item: _historico[index].Item,
                                  Usuario: _historico[index].Usuario,
                                  Quantidade:
                                      _historico[index].Quantidade.toString(),
                                  Membro: _historico[index].Membro);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }));

    overlayState.insert(overlayEntry);
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            color: Colors.white,
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    child: Column(
                      children: [
                        // Top header
                        Flexible(
                          flex: 1,
                          child: Container(
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                'HG',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Sidebar com CustomPaint e ícones
                        Flexible(
                          flex: 12,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                // Background pintado
                                CustomPaint(
                                  size: Size(double.infinity, double.infinity),
                                  painter: RPSCustomPainter(),
                                ),
                                // Ícones na sidebar
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    sidebutom(
                                      icon: Icons.dashboard,
                                      isSelected: _selectedIndex == 0,
                                      onTap: () =>
                                          _onItemTapped(0), // Navegar para Home
                                    ),
                                    sidebutom(
                                      icon: Icons.inventory_sharp,
                                      isSelected: _selectedIndex == 1,
                                      onTap: () => _onItemTapped(
                                          1), // Navegar para Configurações
                                    ),
                                    sidebutom(
                                      icon: Icons.inventory,
                                      isSelected: _selectedIndex == 2,
                                      onTap: () => _onItemTapped(
                                          2), // Navegar para Notificações
                                    ),
                                    sidebutom(
                                      icon: Icons.category,
                                      isSelected: _selectedIndex == 3,
                                      onTap: () => _onItemTapped(3),
                                    ),
                                    sidebutom(
                                      icon: Icons.groups,
                                      isSelected: _selectedIndex == 4,
                                      onTap: () => _onItemTapped(4),
                                    ),
                                    sidebutom(
                                      icon: Icons.history,
                                      isSelected: _selectedIndex == 5,
                                      onTap: () => _onItemTapped(5),
                                    ),
                                    sidebutom(
                                      icon: Icons.save_as_outlined,
                                      isSelected: _selectedIndex == 6,
                                      onTap: () => _onItemTapped(6),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Bottom footer
                        Flexible(
                          flex: 1,
                          child: Container(
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                'HG',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Main content
                Flexible(
                  flex: 14,
                  child: Column(
                    children: [
                      // Header com usuário
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 71.sp,
                          // color: Colors.green,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 50),
                                child: Container(
                                  // color: Colors.red,
                                  height: 70.sp,
                                  width: 240.sp,
                                  child: Center(
                                      child: Image.asset(
                                          "lib/assets/velocitylogo2.png")),
                                ),
                              ),
                              SizedBox(
                                width: 20.sp,
                              ),
                              Container(
                                // color: Colors.amber,
                                child: Row(
                                  children: [
                                    Text(
                                      "WS",
                                      style: TextStyle(
                                        color: Color(0xff01244E),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 25.sp,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.sp,
                                    ), // Bolinha no canto superior direito do texto
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isConnected
                                            ? Colors.green
                                            : Colors
                                                .red, // Verde se conectado, vermelho caso contrário
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30.sp,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          hasNewMovement =
                                              false; // Reseta a bolinha verde quando o ícone for clicado
                                        });
                                        _ListViewNotifi();
                                      },
                                      child: Stack(
                                        children: [
                                          Icon(
                                            size: 30.sp,
                                            PhosphorIcons.bell_fill,
                                            color: Color(0xff01244E),
                                          ),
                                          if (hasNewMovement)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                width:
                                                    12.sp, // Tamanho da bolinha
                                                height:
                                                    12.sp, // Tamanho da bolinha
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .green, // Cor verde para a bolinha
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30.sp,
                                    ),
                                    Icon(
                                      Icons.account_circle,
                                      color: Color(0xff01244E),
                                      size: 42.sp,
                                    ),
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 8.sp,
                                        ),
                                        Text(
                                          textAlign: TextAlign.right,
                                          "${authProvider.userName}",
                                          style: TextStyle(
                                            color: Color(
                                              0xff202020,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22.sp,
                                          ),
                                        ),
                                        Text(
                                          "${authProvider.email}",
                                          style: TextStyle(
                                            color: Color(0xFFADBFD4),
                                            fontSize: 18.sp,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            height: 0,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 30.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 12,
                        child: Container(
                          color: Colors.grey,
                          child: _screens[
                              _selectedIndex], // Exibe a tela selecionada
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// CustomPainter para desenhar o background do menu
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    // Desenho da parte superior
    path.moveTo(size.width * 0.4865700, size.height * 0.09590518);
    path.cubicTo(size.width * 0.1751650, size.height * 0.08124993,
        size.width * 0.03243800, size.height * 0.02586202, 0, 0);
    path.lineTo(0, size.height * 0.5);

    // Desenho da parte inferior
    path.lineTo(0, size.height);
    path.cubicTo(
        size.width * 0.03243800,
        size.height * 0.9741381,
        size.width * 0.1751650,
        size.height * 0.9187503,
        size.width * 0.4865700,
        size.height * 0.9040943);
    path.cubicTo(
        size.width * 0.7979742,
        size.height * 0.8894396,
        size.width * 0.9546000,
        size.height * 0.8462643,
        size.width * 0.9939917,
        size.height * 0.8265086);

    // Fecha o caminho sem desenhar no canto superior direito
    path.lineTo(size.width * 0.9939917, size.height * 0.1734914);
    path.cubicTo(
        size.width * 0.9546000,
        size.height * 0.1537357,
        size.width * 0.7979742,
        size.height * 0.1105603,
        size.width * 0.4865700,
        size.height * 0.09590518);
    path.close();

    Paint paint = Paint()..style = PaintingStyle.fill;
    paint.color = Color(0x01244E).withOpacity(1.0);

    // Desenha o caminho
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Componente para os ícones da sidebar
Widget sidebutom(
    {GestureTapCallback? onTap,
    required IconData icon,
    required bool isSelected}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 20.sp),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.grey[800]
                  : Colors.transparent, // Cor de fundo se selecionado
              borderRadius: BorderRadius.circular(10), // Bordas arredondadas
            ),
            padding:
                EdgeInsets.all(10.sp), // Padding para aumentar a área clicável
            child: Icon(
              icon,
              color: isSelected ? Color(0xffFFB000) : Colors.white,
              size: 40.sp,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _notfiyText(
    {required String? Membro,
    required String horario,
    required String Usuario,
    required String item,
    required String movimentacao,
    required String Quantidade}) {
  String _getNotificacaoTexto() {
    if (movimentacao == 'SAIDA') {
      return '$Membro retirou $Quantidade unidades de $item do estoque.';
    } else if (movimentacao == 'ENTRADA') {
      return '$Quantidade unidades de $item foram adicionadas ao estoque por $Usuario.';
    } else if (movimentacao == "DEVOLUCAO") {
      return '$Quantidade unidades de $item retornaram ao estoque por devolução de $Membro';
    } else {
      return 'Não identificado';
    }
  }

  String _getIcon() {
    if (movimentacao == 'SAIDA') {
      return 'lib/assets/delivery-box_4047598.png';
    } else if (movimentacao == 'ENTRADA') {
      return 'lib/assets/entrada_item.png';
    } else if (movimentacao == "DEVOLUCAO") {
      return 'lib/assets/return_item.png';
    } else {
      return 'lib/assets/service_toolbox.png';
    }
  }

  return Container(
    width: double.infinity,
    // height: 105.sp,
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          width: 1.sp,
          color: Color(0xffA0A6AD),
        ),
      ),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
          child: Row(
            children: [
              Container(
                height: 32.sp,
                width: 32.sp,
                child: Image.asset(_getIcon()),
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: DefaultTextStyle(
                  style: TextStyle(),
                  child: Text(
                    _getNotificacaoTexto(),

                    // '$Membro fez uma retirada de 5 unidades do roteador hauwei.',
                    style: TextStyle(
                      color: Color(0xff01244E),
                      fontSize: 16.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10.sp,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: DefaultTextStyle(
              style: TextStyle(),
              child: Text(
                horario,
                style: TextStyle(
                  color: Color(0xff01244E),
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10.sp,
        ),
      ],
    ),
  );
}
