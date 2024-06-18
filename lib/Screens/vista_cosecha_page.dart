import 'package:cafetero/DataBase/Dao/cosecha_dao.dart';
import 'package:cafetero/Models/cosecha_model.dart';
import 'package:cafetero/Screens/vista_recogidas_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PaginaCosechas extends StatefulWidget {
  const PaginaCosechas({super.key});

  @override
  State<PaginaCosechas> createState() => _PaginaCosechasState();
}

class _PaginaCosechasState extends State<PaginaCosechas> {
  List<CosechaModel> cosechas = [];
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    cargarCosechas();
  }

  Future<void> cargarCosechas() async {
    await initializeDateFormatting('es_ES', null);
    List<CosechaModel> cosechaBD = await CosechaDao().readAll();

    setState(() {
      cosechas = cosechaBD;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'COSECHA',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: cosechas.isEmpty
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
                      'No hay cosechas para mostrar',
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
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: buildDatatable(),
                ),
              ),
      );

  Widget buildDatatable() {
    final columns = [
      'ID',
      'Fecha Inicio',
      'Fecha Fin',
      'Kilos Totales',
      'Recogidas',
      'Venta de café'
    ];

    return SingleChildScrollView(
      // Wrap the DataTable with SingleChildScrollView
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: 1.0,
            ), // Línea negra encima de los nombres de las columnas
          ),
        ),
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith((states) =>
              Color.fromARGB(255, 255, 255, 255) ??
              Color.fromARGB(255, 205, 218, 166)),
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: getColumns(columns),
          rows: getRows(cosechas),
        ),
      ),
    );
  }

  List<DataColumn> getColumns(List<String> columns) {
    return columns.map((String column) {
      switch (column) {
        case 'Fecha Inicio':
        case 'Fecha Fin':
          return DataColumn(
            label: Row(
              children: [
                Text(
                  column,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Icon(
                  Icons.filter_list,
                  color: Colors.black,
                ),
              ],
            ),
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortColumnIndex = columnIndex;
                _sortAscending = ascending;
                _sortData(column, ascending);
              });
            },
          );
        case 'Kilos Totales':
          return DataColumn(
            label: Row(
              children: [
                Text(
                  column,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Icon(
                  Icons.filter_list,
                  color: Colors.black,
                ),
              ],
            ),
            onSort: (columnIndex, ascending) {
              setState(() {
                _sortColumnIndex = columnIndex;
                _sortAscending = ascending;
                _sortData(column, ascending);
              });
            },
          );
        default:
          return DataColumn(
            label: Text(
              column,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
      }
    }).toList();
  }

  void _sortData(String column, bool ascending) {
    setState(() {
      cosechas.sort((a, b) {
        int cmp;
        switch (column) {
          case 'Fecha Inicio':
            cmp = a.fechaInicio.compareTo(b.fechaInicio);
            break;
          case 'Fecha Fin':
            cmp = (a.fechaFin ?? DateTime(2100))
                .compareTo(b.fechaFin ?? DateTime(2100));
            break;
          case 'Kilos Totales':
            cmp = (a.kilosTotales ?? 0).compareTo(b.kilosTotales ?? 0);
            break;
          default:
            cmp = a.idCosecha!.compareTo(b.idCosecha!);
        }
        return ascending ? cmp : -cmp;
      });
    });
  }

  List<DataRow> getRows(List<CosechaModel> cosechas) {
    bool isOdd = false;
    return cosechas.map((CosechaModel cosechas) {
      final color =
          isOdd ? Colors.white : const Color.fromARGB(255, 205, 218, 166);
      isOdd = !isOdd;

      return DataRow(
        color: WidgetStateColor.resolveWith((states) => color),
        cells: [
          DataCell(SizedBox(
              width: 20,
              child: Text(
                cosechas.idCosecha?.toString() ?? 'N/A',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ))),
          DataCell(SizedBox(
              width: 90,
              child: Text(
                DateFormat('dd/MM/yyyy').format(cosechas.fechaInicio),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ))),
          DataCell(SizedBox(
              width: 90,
              child: Text(
                cosechas.fechaFin != null
                    ? DateFormat('dd/MM/yyyy').format(cosechas.fechaFin!)
                    : 'Fecha no disponible',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ))),
          DataCell(SizedBox(
              width: 90,
              child: Text(
                cosechas.kilosTotales.toString(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ))),
          DataCell(InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VistaRecogidasPage()));
              },
              child: const SizedBox(
                width: 90,
                child: Icon(
                  Icons.content_paste_go_outlined,
                  color: Colors.black,
                ),
              ))),
          DataCell(InkWell(
              onTap: () {
                // Define your onTap action here
                print("SI");
              },
              child: const SizedBox(
                width: 90,
                child: Icon(
                  Icons.content_paste_go_outlined,
                  color: Colors.black,
                ),
              )))
        ],
      );
    }).toList();
  }
}
