// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unused_field
import 'package:cafetero/DataBase/Dao/jornal_dao.dart';
import 'package:cafetero/Models/jornal_model.dart';
import 'package:cafetero/Screens/pagos_jornales_page.dart';
import 'package:cafetero/Screens/ver_jornales_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
// ignore: unused_import
import 'package:auto_size_text/auto_size_text.dart';

class PaginaSemanaJornal extends StatefulWidget {
  const PaginaSemanaJornal({Key? key}) : super(key: key);

  @override
  State<PaginaSemanaJornal> createState() => _PaginaSemanaJornalState();
}

class _PaginaSemanaJornalState extends State<PaginaSemanaJornal> {
  List<JornalModel> jornales = [];
  List<Map<String, dynamic>> resultados = [];

  bool isOdd = false;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    cargarJornales();
  }

  Future<void> cargarJornales() async {
    await initializeDateFormatting('es_ES', null);
    List<JornalModel> jornalBD = await JornalDao().readAll();
    List<Map<String, dynamic>> tempResultados = [];
    

    for (JornalModel jornal in jornalBD) {
        try {
          Map<String, dynamic> resultado = await JornalDao().getJornalPorSemanaPago(jornal.idJornal);
          tempResultados.add(resultado);
        } catch (e) {
          print('Error fetching data for id: ${jornal.idJornal} - $e');
        }
      }

    setState(() {   
      jornales = jornalBD;
      resultados = tempResultados;
    });
  }
  

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'JORNALES POR SEMANA',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: resultados.isEmpty
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
      'Pagos Totales',
      'Jornal por Semana',
      'Pago a Trabajadores'
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(
                color: Colors.black,
                width:
                    1.0)),
      ),
      child: DataTable(
        headingRowColor: WidgetStateColor.resolveWith(
            (states) => const Color.fromARGB(255, 255, 255, 255)),
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: getColumns(columns),
        rows: getRows(resultados),
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
        case 'Pagos Totales':
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
    resultados.sort((a, b) {
      int cmp = 0; 

      switch (column) {
        case 'Fecha Inicio':
          final fechaInicioA = DateTime.tryParse(a['fecha_inicio']?.toString() ?? '') ?? DateTime.now();
          final fechaInicioB = DateTime.tryParse(b['fecha_inicio']?.toString() ?? '') ?? DateTime.now();
          cmp = fechaInicioA.compareTo(fechaInicioB);
          break;
        case 'Fecha Fin':
          final fechaFinA = DateTime.tryParse(a['fecha_fin']?.toString() ?? '') ?? DateTime.now();
          final fechaFinB = DateTime.tryParse(b['fecha_fin']?.toString() ?? '') ?? DateTime.now();
          cmp = fechaFinA.compareTo(fechaFinB);
          break;
        case 'Pagos Totales':
          final pagoA = a['pagos'] ?? 0.0;
          final pagoB = b['pagos'] ?? 0.0;
          cmp = pagoA.compareTo(pagoB);
          break;
        default:
          // Handle the default case (column name not found)
          print('Error: Invalid column name: $column');
          break;
      }

      return ascending ? cmp : -cmp;
    });
  });
}


List<DataRow> getRows(List<Map<String, dynamic>> resultados) {
  return resultados.map((Map<String, dynamic> res) {
    final isOdd = resultados.indexOf(res) % 2 == 1;
    final color = isOdd ? const Color.fromARGB(255, 244, 244, 244) : const Color.fromARGB(255, 205, 218, 166); 


    final idSemana = res['id_semana']?.toString() ?? ''; 
    final id = res['id_semana'];
    final inicio =  DateTime.parse(res['fecha_inicio']);
    final fechaInicio = DateFormat('dd/MM/yyyy').format(inicio);

    final fechaFin = res['fecha_fin'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(res['fecha_fin']))
        : 'Fecha no disponible';
    final pagoTotal = res['pagos']?.toString() ?? ''; 


    final dataCells = [
      DataCell(SizedBox(
        width: 20,
        child: Text(idSemana, style: const TextStyle(fontSize: 16)),
      )),
      DataCell(SizedBox(
        width: 90,
        child: Text(fechaInicio, style: const TextStyle(fontSize: 16)),
      )),
      DataCell(SizedBox(
        width: 90,
        child: Text(fechaFin, style: const TextStyle(fontSize: 16)),
      )),
      DataCell(SizedBox(
        width: 90,
        child: Text(pagoTotal, style: const TextStyle(fontSize: 16)),
      )),
      DataCell(InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerJornalesPage(idSemana: id)));
        },
        child: const SizedBox(
          width: 90,
          child: Icon(
            Icons.content_paste_go_outlined,
            color: Colors.black,
          ),
        ),
      )),
      DataCell(InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PagosJornalesPage(semanaActual:id)));
        },
        child: const SizedBox(
          width: 90,
          child: Icon(
            Icons.content_paste_go_outlined,
            color: Colors.black,
          ),
        ),
      )),
    ];
    return DataRow(color: WidgetStateProperty.resolveWith((states) => color), cells: dataCells);}).toList();
  }
}