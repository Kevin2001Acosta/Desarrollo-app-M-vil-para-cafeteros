import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart'; 
import 'package:intl/intl.dart';
import 'package:cafetero/DataBase/Dao/gastos_dao.dart'; 
import 'package:cafetero/Models/gastos_model.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
  final scrollController = ScrollController();
  late List<GastosModel> gastosFiltrados = [];
  bool sortAscending = true;
  int sortColumnIndex = 0;
  List<Color> rowColors = [];

  @override
  void initState() {
    super.initState();
    cargarGastosFiltrados();
    scrollController.addListener(onListen);
  }

  void onListen() {
    setState(() {});
  }

  void cargarGastosFiltrados() async {
    final gastosDao = GastosDao();
    final List<GastosModel> gastos = await gastosDao.filtrarGastos(
      dateRange: widget.selectedDates,
      categories: widget.selectedGastos,
      minAmount: widget.valorMinGasto,
      maxAmount: widget.valorMaxGasto,
    );
    setState(() {
      gastosFiltrados = gastos;
      rowColors = List.generate(gastos.length, (index) => _getRowColor(index));
    });
  }

 Color _getRowColor(int index) {
    return index.isOdd ? Colors.white : const Color.fromARGB(255, 205, 218, 166);
  }

  void onSortCategoria(int columnIndex, bool ascending) {
    setState(() {
      if (columnIndex == sortColumnIndex) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      }
      gastosFiltrados.sort((a, b) {
        int cmp = a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
        return sortAscending ? cmp : -cmp;
      });
      rowColors = List.generate(gastosFiltrados.length, (index) => _getRowColor(index));
    });
  }

  void onSortMonto(int columnIndex, bool ascending) {
    setState(() {
      if (columnIndex == sortColumnIndex) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      }
      gastosFiltrados.sort((a, b) {
        int cmp = a.valor.compareTo(b.valor);
        return sortAscending ? cmp : -cmp;
      });
      rowColors = List.generate(gastosFiltrados.length, (index) => _getRowColor(index));
    });
  }

  void onSortFecha(int columnIndex, bool ascending) {
    setState(() {
      if (columnIndex == sortColumnIndex) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      }
      gastosFiltrados.sort((a, b) {
        int cmp = a.fecha.compareTo(b.fecha);
        return sortAscending ? cmp : -cmp;
      });
      rowColors = List.generate(gastosFiltrados.length, (index) => _getRowColor(index));
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(onListen);
    super.dispose();
  }

  @override
  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'GASTOS',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: gastosFiltrados.isEmpty
         ? const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.black,
                      size: 25,
                    ),
                    SizedBox(width: 8),
                    AutoSizeText(
                      'No hay gastos para mostrar',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      minFontSize: 18.0,
                      maxFontSize: 25.0,
                    ),
                  ],
                ),
              )
          : DataTable2(
              columnSpacing: 5,
              headingRowHeight: 60, 
              dataRowHeight: 50, 
              minWidth: 450,
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => const Color.fromARGB(255, 255, 255, 255)), 
              isHorizontalScrollBarVisible: true,
              columns: [
                DataColumn2(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Categoria ', style: TextStyle(color: Colors.black)),
                      Icon(Icons.filter_list, color: Colors.black),
                    ],
                  ),
                  onSort: onSortCategoria,
                ),
                DataColumn2(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Monto ', style: TextStyle(color: Colors.black)),
                      Icon(Icons.filter_list, color: Colors.black),
                    ],
                  ),
                  numeric: true,
                  onSort: onSortMonto,
                ),
                DataColumn2(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Fecha', style: TextStyle(color: Colors.black)),
                      Icon(Icons.filter_list, color: Colors.black),
                    ],
                  ),
                  onSort: onSortFecha,
                ),
              ],
              rows: gastosFiltrados.asMap().entries.map((entry) {
                final index = entry.key;
                final gasto = entry.value;
                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color>((states) => rowColors[index]),
                  cells: [
                    DataCell(Align(alignment: Alignment.center, child: Text(gasto.nombre, style: const TextStyle(color: Colors.black)))), 
                    DataCell(Align(alignment: Alignment.center, child: Text(gasto.valor.toString(), style: const TextStyle(color: Colors.black)))), 
                    DataCell(Align(alignment: Alignment.center, child: Text(DateFormat('yyyy-MM-dd').format(gasto.fecha), style: const TextStyle(color: Colors.black)))),
                  ],
                );
              }).toList(),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
    );
  }
}


