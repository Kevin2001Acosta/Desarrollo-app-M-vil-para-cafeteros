import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cafetero/Models/recogida_model.dart';
import 'package:cafetero/DataBase/Dao/recogida_dao.dart';
import 'package:cafetero/Screens/pagos_recogidas_page.dart';

class VistaRecogidasPage extends StatefulWidget {
  final int idCosecha;
  const VistaRecogidasPage({super.key, required this.idCosecha});

  @override
  State<VistaRecogidasPage> createState() => _VistaRecogidasPageState();
}

class _VistaRecogidasPageState extends State<VistaRecogidasPage> {
  List<RecogidaModel> recogidas = [];
  bool isOdd = false;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    cargarRecogidas();
  }

  Future<void> cargarRecogidas() async {
    await initializeDateFormatting('es_ES', null);
    List<RecogidaModel> recogidasBD =
        await RecogidaDao().readRecogidaCosecha(widget.idCosecha);

    setState(() {
      recogidas = recogidasBD;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("VISTA RECOGIDAS"),
          titleTextStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: recogidas.isEmpty
            ? const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outlined,
                      color: Colors.black,
                      size: 25,
                    ),
                    SizedBox(width: 8),
                    AutoSizeText(
                      'No hay recogidas para mostrar',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      minFontSize: 18,
                      maxFontSize: 25,
                    )
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
      'Fecha inicio',
      'Fecha fin',
      'Kilos Totales',
      'Registros',
      'Pagos a trabajadores',
    ];

    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 1.0))),
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
              (states) => const Color.fromARGB(255, 255, 255, 255)),
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: getColumns(columns),
          rows: getRows(recogidas),
        ),
      ),
    );
  }

  List<DataColumn> getColumns(List<String> columns) {
    return columns.map((String column) {
      switch (column) {
        case 'Fecha inicio':
        case 'Fecha fin':
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
      recogidas.sort((a, b) {
        int cmp;
        switch (column) {
          case 'Fecha inicio':
            cmp = a.fechaInicio.compareTo(b.fechaInicio);
            break;
          case 'Fecha fin':
            cmp = (a.fechaFin ?? DateTime(2100))
                .compareTo(b.fechaFin ?? DateTime(2100));
            break;
          case 'Kilos Totales':
            cmp = (a.kilosTotales ?? 0).compareTo(b.kilosTotales ?? 0);
            break;
          default:
            cmp = a.idRecogida!.compareTo(b.idRecogida!);
        }
        return ascending ? cmp : -cmp;
      });
    });
  }

  List<DataRow> getRows(List<RecogidaModel> recogidas) {
    return recogidas.map((RecogidaModel recogida) {
      final color =
          isOdd ? Colors.white : const Color.fromARGB(255, 205, 218, 166);
      isOdd = !isOdd;
      return DataRow(
        color: WidgetStateColor.resolveWith((states) => color),
        cells: [
          DataCell(SizedBox(
            width: 20,
            child: Text(
              recogida.idRecogida?.toString() ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          )),
          DataCell(
              Text(recogida.fechaInicio.toIso8601String().substring(0, 10))),
          DataCell(Text(
              recogida.fechaFin?.toIso8601String().substring(0, 10) ?? 'N/A')),
          DataCell(Text(recogida.kilosTotales?.toString() ?? 'N/A')),
          DataCell(InkWell(
              onTap: () {
                print("Funciono");
              },
              child: const SizedBox(
                width: 90,
                child: Icon(
                  Icons.content_paste_go_outlined, // Choose an appropriate icon
                  color: Colors.black,
                ),
              ))),
          DataCell(InkWell(
                onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PagosRecogidasPage(
                              idRecogida: recogida.idRecogida!,
                            )));
              },
              child: const SizedBox(
                width: 90,
                child: Icon(
                  Icons.content_paste_go_outlined, // Choose an appropriate icon
                  color: Colors.black,
                ),
              )))
        ],
      );
    }).toList();
  }
}
