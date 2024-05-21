// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'dart:ffi';
import 'dart:js_interop';

import 'package:cafetero/DataBase/Dao/cosecha_dao.dart';
import 'package:cafetero/Models/cosecha_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class PaginaCosechas extends StatefulWidget 
{
  const PaginaCosechas({Key? key}) : super(key: key);

  @override
  State<PaginaCosechas> createState() => _PaginaCosechasState();
}


class _PaginaCosechasState extends State<PaginaCosechas> 
{
  List<CosechaModel> cosechas = [];
  Set<int> selectedRows = Set<int>();
  @override
  void initState()
  {
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
  Widget build(BuildContext context)  => Scaffold( 
    appBar: AppBar(
      title: const Text('Cosechas Realizadas'),
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
            Text(
              'No hay cosechas para mostrar',
              style: TextStyle(
                fontSize: 25, 
                color: Colors.black, 
              ),
            ),
          ],),
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
    final columns = ['ID', 'Fecha Inicio', 'Fecha Fin', 'Kilos Totales'];

    return DataTable(
      columns: getColumns(columns), 
      rows: getRows(cosechas),);
  }

  
  List<DataColumn> getColumns(List<String> columns) =>
    columns.map((String column) => DataColumn(
      label: Text(column, 
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
        ),
      )
    ).toList();

  
  List<DataRow> getRows(List<CosechaModel> cosechas) =>
  cosechas.map((CosechaModel cosechas) => 
    DataRow(
        selected: true,
        cells: [
          DataCell(Container(
            width: 20,
            child: Text(cosechas.idCosecha?.toString() ?? 'N/A'))
          ),
          DataCell(Container(
            width: 100,
            child: Text(DateFormat('dd/MM/yyyy').format(cosechas.fechaInicio)))
          ),
          DataCell(Container(
            width: 100,
            child: Text(cosechas.fechaFin != null
                    ? DateFormat('dd/MM/yyyy').format(cosechas.fechaFin!)
                    : 'Fecha no disponible'))
          ),
          DataCell(Container(
            width: 100,
            child: Text(cosechas.kilosTotales.toString()))
          ),
        ],
      )
      ).toList();

}