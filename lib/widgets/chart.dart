import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ComparativoMensal extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ComparativoMensal({required this.data});

  @override
  Widget build(BuildContext context) {
    // Processar os dados para o gráfico
    final chartData = data.map((mes) {
      return ChartData(
        referencia: mes['referencia'],
        totalMovimentacoes: mes['totalMovimentacoes'],
      );
    }).toList();

    // Total e percentual do último mês
    final totalUltimoMes = data[0]['totalMovimentacoes'];
    final percentualVariacao =
        data[0]['percentualVariacao'] ?? "+0%"; // Adicionar +0% como fallback
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
                borderRadius: BorderRadius.circular(8),
              ),
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
                            const Text(
                              'Mês',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
                  SizedBox(height: 20.sp),
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
                        '$totalUltimoMes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$percentualVariacao%',
                        style: TextStyle(
                          color: const Color(0xFF4BC57A),
                          fontSize: 25.sp,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15.sp),
                  Container(
                    color: Colors.white,
                    height: 310.sp,
                    width: 390.sp,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <LineSeries<ChartData, String>>[
                        LineSeries<ChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.referencia,
                          yValueMapper: (ChartData data, _) =>
                              data.totalMovimentacoes,
                          color: const Color(0xFF4BC57A),
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class ChartData {
  final String referencia;
  final int totalMovimentacoes;

  ChartData({required this.referencia, required this.totalMovimentacoes});
}
