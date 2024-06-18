import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key, required this.year}) : super(key: key);

  final int year;

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late Future<YearData> yearData;

  @override
  void initState() {
    super.initState();
    yearData = fetchYearData(widget
        .year); // fetchYearData es la función que debes implementar para obtener los datos de la base de datos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: FutureBuilder<YearData>(
        future: yearData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView(
              children: snapshot.data!.months.map((monthData) {
                return Card(
                  child: ListTile(
                    title: Text(monthData.month),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Costo: ${monthData.cost}'),
                        Text('Arrobas vendidas: ${monthData.arrobasSold}'),
                        Text('Venta: ${monthData.sale}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class YearData {
  final List<MonthData> months;

  YearData({required this.months});
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
  // Aquí debes implementar la lógica para obtener los datos de la base de datos
  // Este es solo un ejemplo y debes reemplazarlo con tu propia implementación
  throw UnimplementedError();
}
