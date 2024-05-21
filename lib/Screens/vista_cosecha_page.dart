import 'dart:ffi';

import 'package:cafetero/DataBase/Dao/cosecha_dao.dart';
import 'package:cafetero/Models/cosecha_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PaginaCosechas extends StatefulWidget 
{
  const PaginaCosechas({Key? key}) : super(key: key);

  @override
  State<PaginaCosechas> createState() => _PaginaCosechasState();
}


class _PaginaCosechasState extends State<PaginaCosechas> 
{
  List<CosechaModel> cosechas = [];
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
              Icons.info_outline, // Elige el icono que prefieras
              color: Colors.black, // Color del icono
              size: 25, // Tamaño del icono
            ),
            const SizedBox(width: 8), // Espacio entre el icono y el texto
            Text(
              'No hay cosechas para mostrar',
              style: TextStyle(
                fontSize: 25, // Tamaño de la letra
                color: Colors.black, // Color de la letra
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
      label: Text(column),
      )
    ).toList();

  
  List<DataRow> getRows(List<CosechaModel> cosechas) =>
    cosechas.map((CosechaModel cosechas) => DataRow(
      cells: [
        DataCell(Text(cosechas.idCosecha.toString())),
        DataCell(Text(cosechas.fechaInicio.toString())),
        DataCell(Text(cosechas.fechaFin.toString())),
        DataCell(Text(cosechas.kilosTotales.toString())),
      ],
    )).toList();

}