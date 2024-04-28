import 'package:cafetero/DataBase/Dao/cosecha_dao.dart';
import 'package:cafetero/Models/cosecha_model.dart';
import 'package:cafetero/Screens/trabajo_recogida_page.dart';
//import 'package:cafetero/provider/recogida_provider.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  Future<void> iniciarCosecha(BuildContext context) async {
    //Todo: preguntar si hay una cosecha abierta y así no funcione el botón
    List<Map<String, dynamic>> cosechaIniciada =
        await CosechaDao().cosechaIniciada();

    if (cosechaIniciada.isEmpty) {
      var cosecha = CosechaModel(fechaInicio: DateTime.now());
      await CosechaDao().insert(cosecha);

      if (!context.mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const RecogidaPage()));
    }
  }

  Future<void> finalizarCosecha() async {
    List<Map<String, dynamic>> cosechaIniciada =
        await CosechaDao().cosechaIniciada();
    if (cosechaIniciada.isNotEmpty && cosechaIniciada.length == 1) {
      var cosecha = CosechaModel(
        fechaFin: DateTime.now(),
        idCosecha: cosechaIniciada[0]['id_cosecha'],
        fechaInicio: DateTime.parse(cosechaIniciada[0]['fecha_inicio']),
      );
      await CosechaDao().update(cosecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(title),
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
        ),
        body: const Center(
          child: Text(
            'Bienvenido a la pagina principal',
          ),
        ),
        floatingActionButton:
            Stack(alignment: Alignment.bottomRight, children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () => iniciarCosecha(context),
              tooltip: 'Empezar Cosecha',
              child: const Icon(Icons.agriculture_rounded),
            ),
          ),
          FloatingActionButton(
              heroTag: null,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () => finalizarCosecha(),
              tooltip: 'Finalizar Cosecha',
              child: const Icon(Icons.agriculture_sharp)),
        ]));
  }
}
