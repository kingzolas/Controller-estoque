import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocityestoque/grafico/chart.dart';

import '../services/products_services.dart';

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  final ProductServices _productServices =
      ProductServices('ws://192.168.99.239:3000');

  List<Map<String, dynamic>> _monthlyMovements = []; // Corrigido: Definido aqui

  // Variáveis para armazenar os dados de produtos
  int _newProducts = 0;
  int _usedProducts = 0;
  int _damagedProducts = 0;
  int _totalProducts = 0;
  String _newPercentage = '+0%';
  String _usedPercentage = '+0%';
  String _damagedPercentage = '+0%';
  String _totalPercentage = '+0%';
  int _totalMovimentacoes = 0;

  // Função para carregar os dados
  Future<void> _loadData() async {
    try {
      // Carregar os dados
      final summary = await _productServices.fetchProductSummary();
      final comparativo = await _productServices.fetchComparativoMensal();

      print(comparativo); // Para depuração, pode imprimir a resposta recebida

      setState(() async {
        try {
          // Carregar os dados
          final comparativo = await _productServices.fetchComparativoMensal();
          print(comparativo); // Para depuração, verificar os dados recebidos

          if (comparativo != null &&
              comparativo['data'] != null &&
              comparativo['data'].isNotEmpty) {
            // Iterar pelos dados de cada mês
            List<Map<String, dynamic>> monthlyMovements = [];
            for (var monthData in comparativo['data']) {
              final referencia = monthData['referencia'] ?? 'Sem Referência';
              final totalMovimentacoes =
                  (monthData['totalMovimentacoes'] ?? 0) as int;

              // Inicializar os totais para cada tipo de movimentação
              int totalEntrada = 0;
              int totalSaida = 0;
              int totalDevolucao = 0;

              if (monthData['movimentacoes'] != null) {
                for (var mov in monthData['movimentacoes']) {
                  final tipo = mov['tipoMovimentacao'];
                  final totalQuantidade = (mov['totalQuantidade'] ?? 0) as int;

                  if (tipo == 'ENTRADA') {
                    totalEntrada += totalQuantidade;
                  } else if (tipo == 'SAIDA') {
                    totalSaida += totalQuantidade;
                  } else if (tipo == 'DEVOLUCAO') {
                    totalDevolucao += totalQuantidade;
                  }
                }
              }
              print(monthlyMovements);
              // Adicionar os dados do mês ao resultado final
              monthlyMovements.add({
                'referencia': referencia,
                'totalMovimentacoes': totalMovimentacoes,
                'entrada': totalEntrada,
                'saida': totalSaida,
                'devolucao': totalDevolucao,
              });
            }

            // Atualizar o estado com os dados calculados
            setState(() {
              _monthlyMovements = monthlyMovements;
            });
          }
        } catch (e) {
          // Lidar com erros
          print('Erro ao carregar dados: $e');
        }

        // Para o summary de produtos
        _newProducts =
            (summary['new'] != null && summary['new']['count'] is int)
                ? summary['new']['count'] as int
                : 0;

        _usedProducts =
            (summary['used'] != null && summary['used']['count'] is int)
                ? summary['used']['count'] as int
                : 0;

        _damagedProducts =
            (summary['damaged'] != null && summary['damaged']['count'] is int)
                ? summary['damaged']['count'] as int
                : 0;

        _totalProducts = (summary['total'] != null && summary['total'] is int)
            ? summary['total'] as int
            : 0;

        _newPercentage = (summary['new'] != null &&
                summary['new']['percent'] is String &&
                summary['new']['percent'].isNotEmpty)
            ? summary['new']['percent']
            : '0%';

        _usedPercentage =
            (summary['used'] != null && summary['used']['percent'] is String)
                ? summary['used']['percent'] as String
                : '0%';

        _damagedPercentage = (summary['damaged'] != null &&
                summary['damaged']['percent'] is String)
            ? summary['damaged']['percent'] as String
            : '0%';

        _totalPercentage = '100%'; // Ou algum outro valor desejado
      });
    } catch (e) {
      // Lidar com erros de forma adequada
      print('Erro ao carregar dados: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 45, right: 45, top: 10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Color(0xFF01244E),
                      fontSize: 57.17.sp,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 460.sp,
                      height: 830.sp,
                      decoration: ShapeDecoration(
                        color: Color(0xFF193F6C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 15.sp,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15.sp,
                              ),
                              _ContainerStatus(
                                  icone: PhosphorIcons.smiley_fill,
                                  status: 'Novo',
                                  number: '$_newProducts',
                                  percentual: _newPercentage),
                              SizedBox(
                                width: 10.sp,
                              ),
                              _ContainerStatus(
                                  icone: PhosphorIcons.smiley_meh_fill,
                                  status: 'Usados',
                                  number: '$_usedProducts',
                                  percentual: _usedPercentage)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 15),
                            child: Row(
                              children: [
                                _ContainerStatus(
                                    icone: PhosphorIcons.smiley_x_eyes_fill,
                                    status: "Danificados",
                                    number: '$_damagedProducts',
                                    percentual: _damagedPercentage),
                                SizedBox(
                                  width: 10.sp,
                                ),
                                _ContainerStatus(
                                    icone: PhosphorIcons.codesandbox_logo_fill,
                                    status: 'Todos',
                                    number: '$_totalProducts',
                                    percentual: _totalPercentage)
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15.sp,
                          ),
                          ChartSyncfusion()
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 21.sp,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 555.50.sp,
                              height: 330.sp,
                              decoration: ShapeDecoration(
                                color: Color(0xFF01244E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.sp,
                            ),
                            Container(
                              width: 555.50.sp,
                              height: 330.sp,
                              decoration: ShapeDecoration(
                                color: Color(0xFF01244E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10.sp,
                        ),
                        Container(
                            width: 1121.sp,
                            height: 490.sp,
                            decoration: ShapeDecoration(
                              color: Color(0xFF01244E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ))
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget para exibir os status
Widget _ContainerStatus(
    {required IconData icone,
    required String status,
    required String number,
    required String percentual}) {
  return ScreenUtilInit(
    designSize: const Size(1920, 1080),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) {
      return Container(
        width: 210.sp,
        height: 150.sp,
        decoration: ShapeDecoration(
          color: Color(0xFF01244E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: Row(
                children: [
                  Icon(
                    icone,
                    color: Colors.white,
                    size: 35.sp,
                  ),
                  SizedBox(
                    width: 6.sp,
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30.sp,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  number,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35.sp,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${percentual}%',
                        style: TextStyle(
                          color: Color(0xFF4BC57A),
                          fontSize: 15.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                      TextSpan(
                        text: ' ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                      TextSpan(
                        text: 'Percentual',
                        style: TextStyle(
                          color: Color(0xFFB0C1D5),
                          fontSize: 12.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}
