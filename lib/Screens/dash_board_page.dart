import 'package:cafetero/DataBase/Dao/gastos_dao.dart';
import 'package:cafetero/DataBase/Dao/ventas_cafe_dao.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.year});

  final int year;

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late Future<YearData> yearData;

  @override
  void initState() {
    super.initState();
    yearData =
        fetchYearData(widget.year); // fetchYearData llamado a base de datos
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Dashboard ${widget.year}',
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Costos'),
              Tab(text: 'Arrobas'),
              Tab(text: 'Ventas'),
              Tab(text: 'Totales'),
            ],
          ),
        ),
        body: FutureBuilder<YearData>(
          future: yearData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return TabBarView(
                children: [
                  ListView(
                    children:
                        snapshot.data!.months.asMap().entries.map((entry) {
                      MonthData monthData = entry.value;
                      int cost = int.parse(monthData.cost);
                      String formattedCost = NumberFormat('#,##0').format(cost);
                      int index = entry.key;

                      return Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 8.0 : 0),
                        child: Card(
                          color: const Color.fromARGB(255, 205, 218, 166),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            height: 60,
                            child: Row(
                              children: [
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        monthMap(monthData.month),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    )),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Text('$formattedCost \$',
                                        style: const TextStyle(fontSize: 20))),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ListView(
                    children:
                        snapshot.data!.months.asMap().entries.map((entry) {
                      int index = entry.key;
                      MonthData monthData = entry.value;
                      double arrobasSold = double.parse(monthData.arrobasSold);

                      String formattedArrobasSold =
                          NumberFormat('#,##0.00').format(arrobasSold);
                      return Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 8.0 : 0),
                        child: Card(
                          color: const Color.fromARGB(255, 205, 218, 166),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            height: 60,
                            child: Row(
                              children: [
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        monthMap(monthData.month),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    )),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Text('$formattedArrobasSold @',
                                        style: const TextStyle(fontSize: 20))),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ListView(
                    children:
                        snapshot.data!.months.asMap().entries.map((entry) {
                      int index = entry.key;
                      MonthData monthData = entry.value;
                      int sale = int.parse(monthData.sale);
                      String formattedSale = NumberFormat('#,##0').format(sale);
                      return Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 8.0 : 0),
                        child: Card(
                          color: const Color.fromARGB(255, 205, 218, 166),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            height: 60,
                            child: Row(
                              children: [
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        monthMap(monthData.month),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    )),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Text('$formattedSale \$',
                                        style: const TextStyle(fontSize: 20))),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 420,
                            height: 260,
                            child: Card(
                              color: const Color.fromARGB(255, 205, 218, 166),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            child: const Text(
                                              'Total Costo:',
                                              style: TextStyle(fontSize: 19),
                                            )),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: Text(
                                              '${NumberFormat('#,##0').format(snapshot.data!.totalCost)}\$',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            child: const Text(
                                              'Total @ vendidas:',
                                              style: TextStyle(fontSize: 18),
                                            )),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: Text(
                                              '${snapshot.data!.totalArrobasSold}',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            child: const Text(
                                              'Total Ventas:',
                                              style: TextStyle(fontSize: 18),
                                            )),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: Text(
                                              '${NumberFormat('#,##0').format(snapshot.data!.totalSales)}\$',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            child: const Text(
                                              'Costo por @:',
                                              style: TextStyle(fontSize: 18),
                                            )),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: Text(
                                              '${NumberFormat('#,##0.00').format(snapshot.data!.costoArroba)}\$',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            child: const Text(
                                              'Precio Libre por @:',
                                              style: TextStyle(fontSize: 18),
                                            )),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: Text(
                                              '${NumberFormat('#,##0.00').format(snapshot.data!.precioLibreArroba)}\$',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            child: const Text(
                                              'Precio Venta por @:',
                                              style: TextStyle(fontSize: 18),
                                            )),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: Text(
                                              '${NumberFormat('#,##0.00').format(snapshot.data!.precioVentaArroba)}\$',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            child: const Text(
                                              'Rentabilidad:',
                                              style: TextStyle(fontSize: 18),
                                            )),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          child: Text(
                                              '${NumberFormat('#,##0.00').format(snapshot.data!.rentabilidad)}%',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: 50,
                            child: const Text(
                              'Costos',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.brown),
                            ),
                          ),
                          SizedBox(
                            height: 350,
                            width: 470,
                            child: BarChart(BarChartData(
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    String month = monthMap(snapshot.data!
                                        .months[group.x.toInt() - 1].month);
                                    String cost = snapshot
                                        .data!.months[group.x.toInt() - 1].cost;
                                    return BarTooltipItem(
                                      '$month\nCosto: ${NumberFormat('#,##0').format((int.parse(cost)))} \$',
                                      const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                //show: true,
                                bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 24,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 1:
                                        return const Text('En');
                                      case 2:
                                        return const Text('Feb');
                                      case 3:
                                        return const Text('Mar');
                                      case 4:
                                        return const Text('Abr');
                                      case 5:
                                        return const Text('May');
                                      case 6:
                                        return const Text('jun');
                                      case 7:
                                        return const Text('jul');
                                      case 8:
                                        return const Text('Ago');
                                      case 9:
                                        return const Text('Sep');
                                      case 10:
                                        return const Text('Oct');
                                      case 11:
                                        return const Text('Nov');
                                      case 12:
                                        return const Text('Dic');
                                      // Agrega más casos según sea necesario
                                      default:
                                        return const Text('');
                                    }
                                  },
                                )),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                )),
                              ),
                              borderData: FlBorderData(show: true),
                              gridData: FlGridData(
                                checkToShowVerticalLine: (value) =>
                                    value % 1 == 0,
                              ),
                              baselineY: 0,
                              barGroups: snapshot.data!.months.map((monthData) {
                                double cost;
                                try {
                                  cost = double.parse(monthData.cost);
                                } catch (e) {
                                  cost =
                                      0.0; // Use a default value or handle the error as appropriate for your application
                                }
                                int x = int.tryParse(monthData.month) ?? 10;

                                return BarChartGroupData(x: x, barRods: [
                                  BarChartRodData(
                                    width: 22,
                                    toY: cost,
                                    color: const Color(0xFFBBA666),
                                  )
                                ]);
                              }).toList(),
                            )),
                          )
                        ],
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: 50,
                            child: const Text(
                              'arrobas vendidas',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.brown),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            height: 300,
                            width: 470,
                            child: LineChart(LineChartData(
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((touchedSpot) {
                                        final month = monthMap(snapshot
                                            .data!
                                            .months[touchedSpot.spotIndex]
                                            .month);
                                        final arrobasSold = snapshot
                                            .data!
                                            .months[touchedSpot.spotIndex]
                                            .arrobasSold;
                                        return LineTooltipItem(
                                            '$month\n@ vendidas: $arrobasSold @',
                                            const TextStyle(
                                                color: Colors.white));
                                      }).toList();
                                    },
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                      barWidth: 5,
                                      isCurved: true,
                                      color: Colors.brown,
                                      spots: snapshot.data!.months
                                          .map((monthData) {
                                        double x =
                                            double.tryParse(monthData.month) ??
                                                10;
                                        double y = double.tryParse(
                                                monthData.arrobasSold) ??
                                            0;
                                        return FlSpot(x, y);
                                      }).toList())
                                ],
                                titlesData: const FlTitlesData(
                                    rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    bottomTitles:
                                        AxisTitles(axisNameSize: 20)))),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: 50,
                            child: const Text(
                              'Ingresos y gastos',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.green),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            height: 300,
                            width: 470,
                            child: LineChart(LineChartData(
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    maxContentWidth: 350,
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((touchedSpot) {
                                        if (touchedSpot.barIndex == 0) {
                                          final month = monthMap(snapshot
                                              .data!
                                              .months[touchedSpot.spotIndex]
                                              .month);
                                          final sale = snapshot
                                              .data!
                                              .months[touchedSpot.spotIndex]
                                              .sale;
                                          final cost = snapshot
                                              .data!
                                              .months[touchedSpot.spotIndex]
                                              .cost;
                                          return LineTooltipItem(
                                              '$month\nIngresos: ${NumberFormat('#,##0').format(int.parse(sale))} \$\nGastos: ${NumberFormat('#,##0').format(int.parse(cost))} \$',
                                              const TextStyle(
                                                  color: Colors.white));
                                        } else {
                                          return null;
                                        }
                                      }).toList();
                                    },
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    barWidth: 5,
                                    isCurved: true,
                                    color: Colors.green,
                                    spots:
                                        snapshot.data!.months.map((monthData) {
                                      double x =
                                          double.tryParse(monthData.month) ??
                                              10;
                                      double y =
                                          double.tryParse(monthData.sale) ?? 0;
                                      return FlSpot(x, y);
                                    }).toList(),
                                  ),
                                  LineChartBarData(
                                      barWidth: 5,
                                      isCurved: true,
                                      color: Colors.red,
                                      spots: snapshot.data!.months
                                          .map((monthData) {
                                        double x =
                                            double.tryParse(monthData.month) ??
                                                10;
                                        double y =
                                            double.tryParse(monthData.cost) ??
                                                0;
                                        return FlSpot(x, y);
                                      }).toList())
                                ],
                                titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 50,
                                    )),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                        axisNameSize: 20,
                                        sideTitles: SideTitles(
                                          getTitlesWidget: (value, meta) {
                                            switch (value.toInt()) {
                                              case 1:
                                                return const Text('En');
                                              case 2:
                                                return const Text('Feb');
                                              case 3:
                                                return const Text('Mar');
                                              case 4:
                                                return const Text('Abr');
                                              case 5:
                                                return const Text('May');
                                              case 6:
                                                return const Text('jun');
                                              case 7:
                                                return const Text('jul');
                                              case 8:
                                                return const Text('Ago');
                                              case 9:
                                                return const Text('Sep');
                                              case 10:
                                                return const Text('Oct');
                                              case 11:
                                                return const Text('Nov');
                                              case 12:
                                                return const Text('Dic');
                                              // Agrega más casos según sea necesario
                                              default:
                                                return const Text('');
                                            }
                                          },
                                        ))))),
                          )
                        ],
                      )
                    ],
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

String monthMap(String digito) {
  Map<String, String> monthmap = {
    '01': 'Enero',
    '02': 'Febrero',
    '03': 'Marzo',
    '04': 'Abril',
    '05': 'Mayo',
    '06': 'Junio',
    '07': 'Julio',
    '08': 'Agosto',
    '09': 'Septiembre',
    '10': 'Octubre',
    '11': 'Noviembre',
    '12': 'Diciembre',
  };
  return monthmap[digito]!;
}

class YearData {
  final List<MonthData> months;
  late final int totalCost;
  late final double totalArrobasSold;
  late final int totalSales;

  late final double costoArroba;
  late final double precioLibreArroba;
  late final double precioVentaArroba;
  late final double rentabilidad;

  YearData({required this.months}) {
    totalCost = months.fold(0, (sum, month) => sum + int.parse(month.cost));
    totalArrobasSold =
        months.fold(0, (sum, month) => sum + double.parse(month.arrobasSold));
    totalSales = months.fold(0, (sum, month) => sum + int.parse(month.sale));

    costoArroba = totalArrobasSold == 0 ? 0 : totalCost / totalArrobasSold;
    precioLibreArroba =
        totalArrobasSold == 0 ? 0 : (totalSales - totalCost) / totalArrobasSold;
    precioVentaArroba =
        totalArrobasSold == 0 ? 0 : totalSales / totalArrobasSold;
    rentabilidad =
        totalCost == 0 ? 0 : ((totalSales - totalCost) / totalCost) * 100;
  }
}

class MonthData {
  final String month;
  final String cost;
  final String arrobasSold;
  final String sale;

  MonthData({
    required this.month,
    required this.cost,
    required this.arrobasSold,
    required this.sale,
  });
}

Future<YearData> fetchYearData(int year) async {
  final ventas = await VentasCafeDao().getVentasbyMes(year.toString());
  final gastos = await GastosDao().getGastosbyYear(year.toString());

  // Mapear los resultados a la clase MonthData
  final months = List<MonthData>.generate(12, (i) {
    final mes = (i + 1).toString().padLeft(2, '0');

    final venta = ventas.firstWhere((v) => v['mes'] == mes,
        orElse: () => {'arrobas_vendidas': 0, 'venta_total': 0});
    final gasto =
        gastos.firstWhere((g) => g['mes'] == mes, orElse: () => {'costo': 0});

    return MonthData(
      month: mes,
      cost: gasto['costo'].toString(),
      arrobasSold: venta['arrobas_vendidas'].toString(),
      sale: venta['venta_total'].toString(),
    );
  });

  return YearData(months: months);
}
