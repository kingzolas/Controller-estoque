import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:velocityestoque/screens/create_members.dart';
import 'package:velocityestoque/gerenciador.dart';
import 'package:velocityestoque/models/auth_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0; // Índice da tela selecionada

  // Lista de telas
  final List<Widget> _screens = [
    HomeScreen(),
    SettingsScreen(),
    NotificationsScreen(),
    Category(),
    CreateMemberPage(),
    History()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Atualiza o índice da tela selecionada
    });
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
                              Row(
                                children: [
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
