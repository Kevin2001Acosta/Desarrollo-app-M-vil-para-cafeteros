import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart'; // Importa el paquete de DataTable2
import 'package:intl/intl.dart';
import 'package:cafetero/DataBase/Dao/gastos_dao.dart'; // Asegúrate de importar los DAO y modelos necesarios
import 'package:cafetero/Models/gastos_model.dart';

class VerGastosPage extends StatefulWidget {
  final DateTimeRange? selectedDates;
  final List<String> selectedGastos;
  final int? valorMinGasto;
  final int? valorMaxGasto;

  const VerGastosPage({
    Key? key,
    required this.selectedDates,
    required this.selectedGastos,
    required this.valorMinGasto,
    required this.valorMaxGasto,
  }) : super(key: key);

  @override
  _VerGastosPageState createState() => _VerGastosPageState();
}

class _VerGastosPageState extends State<VerGastosPage> {
  late List<GastosModel> gastosFiltrados; // Lista para almacenar los gastos filtrados

  @override
  void initState() {
    super.initState();
    cargarGastosFiltrados();
  }

  // Función para cargar los gastos filtrados desde la base de datos
  void cargarGastosFiltrados() async {
    // Lógica para filtrar los gastos según los parámetros recibidos
     // Actualiza el estado para reflejar los cambios en la UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gastos Filtrados'),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable2(
            columns: [
              // Define las columnas del DataTable2
              DataColumn2(label: Text('Fecha')),
              DataColumn2(label: Text('Tipo')),
              DataColumn2(label: Text('Valor')),
            ],
            rows: gastosFiltrados.map((gasto) {
              return DataRow(cells: [
                DataCell(Text(DateFormat('yyyy-MM-dd').format(gasto.fecha))),
                DataCell(Text(gasto.nombre)),
                DataCell(Text(gasto.valor.toString())),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

