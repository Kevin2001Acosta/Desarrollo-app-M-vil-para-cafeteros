import 'package:cafetero/DataBase/Dao/m_semana_dao.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

const itemSize = 120.0;

class PagosJornalesPage extends StatefulWidget {
  final int semanaActual;
  const PagosJornalesPage({required this.semanaActual, super.key});

  @override
  State<PagosJornalesPage> createState() => _PagosJornalesPageState();
}

class _PagosJornalesPageState extends State<PagosJornalesPage> {
  final scrollController = ScrollController();
  List<Map<String, dynamic>> pagosTrabajadores = [];

  bool sortAscending = true;
  int sortColumnIndex = 0;

  void onListen() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getpagosTrabajadores(); // Obtén los datos de SQLite
    scrollController.addListener(onListen);
  }

  void getpagosTrabajadores() async {
    final pagos = await MSemanaDao().pagosSemana(widget.semanaActual);
    setState(() {
      pagosTrabajadores = pagos;
    });
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
    List<Map<String, dynamic>> pagosTrabajadoresModificable =
        List.from(pagosTrabajadores);
    if (sortAscending) {
      pagosTrabajadoresModificable
          .sort((a, b) => a['id_trabajador'].compareTo(b['id_trabajador']));
    } else {
      pagosTrabajadoresModificable
          .sort((a, b) => b['id_trabajador'].compareTo(a['id_trabajador']));
    }
    setState(() {
      pagosTrabajadores = pagosTrabajadoresModificable;
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
    List<Map<String, dynamic>> pagosTrabajadoresModificable =
        List.from(pagosTrabajadores);
    if (sortAscending) {
      pagosTrabajadoresModificable
          .sort((a, b) => a['nombre'].compareTo(b['nombre']));
    } else {
      pagosTrabajadoresModificable
          .sort((a, b) => b['nombre'].compareTo(a['nombre']));
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
    List<Map<String, dynamic>> pagosTrabajadoresModificable =
        List.from(pagosTrabajadores);
    if (sortAscending) {
      pagosTrabajadoresModificable
          .sort((a, b) => a['pago_total'].compareTo(b['pago_total']));
    } else {
      pagosTrabajadoresModificable
          .sort((a, b) => b['pago_total'].compareTo(a['pago_total']));
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
          'PAGOS DE JORNALES',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: DataTable2(
        columnSpacing: 5,
        headingRowHeight: 80,
        dataRowHeight: 60,
        minWidth: 650,

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
                Text('PAGO TOTAL ', style: TextStyle(color: Colors.black)),
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
                    Text('JORNALES ', style: TextStyle(color: Colors.black))),
            numeric: true,
          )
        ],
        rows: pagosTrabajadores.map((pago) {
          int idx = pagosTrabajadores.indexOf(pago);
          return DataRow(
            color: idx % 2 == 0
                ? MaterialStateColor.resolveWith(
                    (states) => const Color(0xFFB4F0B6))
                : MaterialStateColor.resolveWith(
                    (states) => Colors.transparent),
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
