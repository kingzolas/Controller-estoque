import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:velocityestoque/baseConect.dart';
import 'package:velocityestoque/services/products_services.dart';

class ChartSyncfusion extends StatefulWidget {
  const ChartSyncfusion({super.key});

  @override
  State<ChartSyncfusion> createState() => _ChartState();
}

class _ChartState extends State<ChartSyncfusion> with TickerProviderStateMixin {
  final ProductServices _productServices =
      ProductServices('ws://${Socket.apiUrl}');

  List<Map<String, dynamic>> _monthlyMovements = [];
  int _currentMonthTotal = 0;
  double _percentageChange = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadData();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward(); // Inicia a animação automaticamente ao carregar os dados

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      final comparativo = await _productServices.fetchComparativoMensal();
      if (comparativo != null &&
          comparativo['data'] != null &&
          comparativo['data'].isNotEmpty) {
        List<Map<String, dynamic>> monthlyMovements = [];
        for (var monthData in comparativo['data']) {
          final referencia = monthData['referencia'] ?? 'Sem Referência';
          final totalMovimentacoes =
              (monthData['totalMovimentacoes'] ?? 0) as int;
          monthlyMovements.add({
            'referencia': referencia,
            'totalMovimentacoes': totalMovimentacoes,
          });
        }

        setState(() {
          _monthlyMovements = monthlyMovements;

          if (_monthlyMovements.length >= 2) {
            _currentMonthTotal = _monthlyMovements[0]['totalMovimentacoes'];
            int previousMonthTotal = _monthlyMovements[1]['totalMovimentacoes'];
            if (previousMonthTotal > 0) {
              _percentageChange = ((_currentMonthTotal - previousMonthTotal) /
                      previousMonthTotal) *
                  100;
            } else {
              _percentageChange = 100;
            }
          } else if (_monthlyMovements.length == 1) {
            _currentMonthTotal = _monthlyMovements[0]['totalMovimentacoes'];
            _percentageChange = 100;
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Container(
            width: 430.sp,
            height: 470.sp,
            decoration: ShapeDecoration(
              color: const Color(0xFF01244E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Movimentações ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        width: 100.sp,
                        height: 30.sp,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF193F6C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Mês',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.sp,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total de movimentações',
                      style: TextStyle(
                        color: const Color(0xFFB0C1D5),
                        fontSize: 18.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentMonthTotal.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _percentageChange >= 0
                            ? '+${_percentageChange.toStringAsFixed(2)}%'
                            : '${_percentageChange.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: _percentageChange >= 0
                              ? const Color(0xFF4BC57A)
                              : const Color(0xFFFF4C4C),
                          fontSize: 25.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15.sp,
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            title: AxisTitle(
                              text: 'Meses',
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            labelStyle: TextStyle(color: Colors.white),
                            // Adicionando a propriedade reverse para inverter a ordem
                            isInversed:
                                true, // Esta propriedade inverte a direção do eixo X
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(
                              text: 'Movimentações',
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.transparent,
                          series: <SplineAreaSeries<Map<String, dynamic>,
                              String>>[
                            SplineAreaSeries<Map<String, dynamic>, String>(
                              dataSource: _monthlyMovements,
                              xValueMapper: (data, _) =>
                                  data['referencia'] ?? '',
                              yValueMapper: (data, _) =>
                                  (data['totalMovimentacoes'] ?? 0) *
                                  _animation.value,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4BC57A), Color(0xFF193F6C)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderWidth: 2,
                              borderColor: const Color(0xFF4BC57A),
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(
                                    color: Colors.white, fontSize: 12.sp),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
