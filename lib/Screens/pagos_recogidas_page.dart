import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cafetero/DataBase/Dao/recogida_dao.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PagosRecogidasPage extends StatefulWidget {
  final int idRecogida;
  const PagosRecogidasPage({Key? key, required this.idRecogida}) : super(key: key);

  @override
  State<PagosRecogidasPage> createState() => _PagosRecogidasPage();
}

class _PagosRecogidasPage extends State<PagosRecogidasPage> {
  final scrollController = ScrollController();
  List<Map<String, dynamic>> pagosTrabajadores = [];
  bool isOdd = false;
  List<Color> rowColors = [];

  bool sortAscending = true;
  int sortColumnIndex = 0;

  void onListen() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getPagosTrabajadores(); 
    scrollController.addListener(onListen);
  }

  Future<void> getPagosTrabajadores() async {
      final pagos = await RecogidaDao().pagosRecogida(widget.idRecogida);
      setState(() {
        pagosTrabajadores = pagos;
          rowColors = List.generate(pagos.length, (index) => _getRowColor(index));
      });   
  }

  Color _getRowColor(int index) {
    return index.isOdd ? Colors.white : const Color.fromARGB(255, 205, 218, 166);
  }

  @override
  void dispose() {
    scrollController.removeListener(onListen);
    super.dispose();
  }

  void onSortID(int columnIndex, bool ascending) {
    if (columnIndex == sortColumnIndex) {
      setState(() {
        sortAscending = !sortAscending;
      });
    } else {
      setState(() {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      });
    }
    List<Map<String, dynamic>> pagosTrabajadoresModificable = List.from(pagosTrabajadores);
    if (sortAscending) {
      pagosTrabajadoresModificable.sort((a, b) => a['id_trabajador'].compareTo(b['id_trabajador']));
    } else {
      pagosTrabajadoresModificable.sort((a, b) => b['id_trabajador'].compareTo(a['id_trabajador']));
    }
    setState(() {
      pagosTrabajadores = pagosTrabajadoresModificable;
       rowColors = List.generate(pagosTrabajadores.length, (index) => _getRowColor(index));
    });
  }

  void onSortNombre(int columnIndex, bool ascending) {
    if (columnIndex == sortColumnIndex) {
      setState(() {
        sortAscending = !sortAscending;
      });
    } else {
      setState(() {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      });
    }
    List<Map<String, dynamic>> pagosTrabajadoresModificable = List.from(pagosTrabajadores);
    if (sortAscending) {
      pagosTrabajadoresModificable.sort((a, b) => a['nombre'].toString().toLowerCase().compareTo(b['nombre'].toString().toLowerCase()));
    } else {
      pagosTrabajadoresModificable.sort((a, b) => b['nombre'].toString().toLowerCase().compareTo(a['nombre'].toString().toLowerCase()));
    }
    setState(() {
      pagosTrabajadores = pagosTrabajadoresModificable;
    });
  }

  void onSortPago(int columnIndex, bool ascending) {
    if (columnIndex == sortColumnIndex) {
      setState(() {
        sortAscending = !sortAscending;
      });
    } else {
      setState(() {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      });
    }
    List<Map<String, dynamic>> pagosTrabajadoresModificable = List.from(pagosTrabajadores);
    if (sortAscending) {
      pagosTrabajadoresModificable.sort((a, b) => a['pago_total'].compareTo(b['pago_total']));
    } else {
      pagosTrabajadoresModificable.sort((a, b) => b['pago_total'].compareTo(a['pago_total']));
    }
    setState(() {
      pagosTrabajadores = pagosTrabajadoresModificable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'PAGOS DE RECOGIDAS',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: pagosTrabajadores.isEmpty
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
                      'No hay pagos para los recogidas',
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
        headingRowHeight: 80,
        dataRowHeight: 60,
        minWidth: 650,
        headingRowColor: MaterialStateColor.resolveWith(
            (states) => const Color.fromARGB(255, 255, 255, 255)),

        isHorizontalScrollBarVisible: true,
        columns: [
          DataColumn2(
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ID ', style: TextStyle(color: Colors.black)),
                Icon(
                  Icons.filter_list,
                  color: Colors.black,
                ),
              ],
            ),
            numeric: true,
            size: ColumnSize.S,
            onSort: onSortID,
          ),
          DataColumn2(
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('NOMBRE ', style: TextStyle(color: Colors.black)),
                Icon(
                  Icons.filter_list,
                  color: Colors.black,
                ),
              ],
            ),
            onSort: onSortNombre,
          ),
          DataColumn2(
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('PAGO ', style: TextStyle(color: Colors.black)),
                Icon(
                  Icons.filter_list,
                  color: Colors.black,
                ),
              ],
            ),
            numeric: true,
            onSort: onSortPago,
          ),
          const DataColumn2(
            label: Center(
                child:
                    Text('KILOS TOTALES', style: TextStyle(color: Colors.black))),
            numeric: true,
          ),
          const DataColumn2(
            label: Center(
                child:
                    Text('JORNALES ', style: TextStyle(color: Colors.black))),
            numeric: true,
          )
        ],
        rows: pagosTrabajadores.asMap().entries.map((entry) {
          final index = entry.key;
          final pago = entry.value;
          return DataRow(
            color: MaterialStateProperty.resolveWith<Color>((states) => rowColors[index]),
            cells: pago.entries.map((e) {
              return DataCell(Align(
                alignment: Alignment.center,
                child: Text(
                  e.value.toString(),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ));
            }).toList(),
          );
        }).toList(),
        //horizontalScrollController: ,
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}

