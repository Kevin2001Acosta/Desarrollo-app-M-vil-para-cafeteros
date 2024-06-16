// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables
import 'package:cafetero/DataBase/Dao/cosecha_dao.dart';
import 'package:cafetero/Models/cosecha_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PaginaCosechas extends StatefulWidget {
  const PaginaCosechas({Key? key}) : super(key: key);

  @override
  State<PaginaCosechas> createState() => _PaginaCosechasState();
}

class _PaginaCosechasState extends State<PaginaCosechas> {
  List<CosechaModel> cosechas = [];
  bool isOdd = false;
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
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.black,
                      size: 25,
                    ),
                    const SizedBox(width: 8),
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

    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: Colors.black,
                width:
                    1.0)), // Línea negra encima de los nombres de las columnas
      ),
      child: DataTable(
        headingRowColor: MaterialStateColor.resolveWith((states) =>
            Color.fromARGB(255, 255, 255, 255) ??
            Color.fromARGB(255, 205, 218, 166)),
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: getColumns(columns),
        rows: getRows(cosechas),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  List<DataRow> getRows(List<CosechaModel> cosechas) =>
      cosechas.map((CosechaModel cosechas) {
        final color = isOdd ? Colors.white : Color.fromARGB(255, 205, 218, 166);
        isOdd = !isOdd;
        return DataRow(
          color: MaterialStateProperty.resolveWith<Color>((states) => color),
          cells: [
            DataCell(Container(
                width: 20,
                child: Text(
                  cosechas.idCosecha?.toString() ?? 'N/A',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ))),
            DataCell(Container(
                width: 90,
                child: Text(
                  DateFormat('dd/MM/yyyy').format(cosechas.fechaInicio),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ))),
            DataCell(Container(
                width: 90,
                child: Text(
                  cosechas.fechaFin != null
                      ? DateFormat('dd/MM/yyyy').format(cosechas.fechaFin!)
                      : 'Fecha no disponible',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ))),
            DataCell(Container(
                width: 90,
                child: Text(
                  cosechas.kilosTotales.toString(),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ))),
            DataCell(InkWell(
                onTap: () {
                  print("SI");
                },
                child: Container(
                  width: 90,
                  child: Icon(
                    Icons
                        .content_paste_go_outlined, // Choose an appropriate icon
                    color: Colors.black,
                  ),
                ))),
            DataCell(InkWell(
                onTap: () {
                  // Define your onTap action here
                  print("SI");
                },
                child: Container(
                  width: 90,
                  child: Icon(
                    Icons
                        .content_paste_go_outlined, // Choose an appropriate icon
                    color: Colors.black,
                  ),
                )))
          ],
        );
      }).toList();
}
