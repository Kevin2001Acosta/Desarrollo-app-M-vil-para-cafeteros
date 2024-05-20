import 'dart:io';
import 'package:cafetero/DataBase/Dao/cosecha_dao.dart';
import 'package:cafetero/Models/cosecha_model.dart';
import 'package:cafetero/Screens/gastos_page.dart';
import 'package:cafetero/Screens/trabajadores_page.dart';
import 'package:cafetero/Screens/trabajo_recogida_page.dart';
import 'package:cafetero/provider/cosecha_provider.dart';
import 'package:cafetero/provider/recogida_provider.dart';
//import 'package:cafetero/provider/recogida_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
// url de pdf info café: https://federaciondecafeteros.org/app/uploads/2019/10/precio_cafe.pdf

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // scrapping para obtener el precio del café
  void peticion() async {
    try {
      final response = await http.get(
          Uri.parse('https://federaciondecafeteros.org/wp/publicaciones/'));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final priceElement = document.querySelector('li > strong');

        if (priceElement != null) {
          final price = priceElement.text;
          print('The price is $price');
        } else {
          print('Price element not found');
        }
      }
    } on SocketException catch (_) {
      print('No Internet connection');
    } catch (e) {
      print(e);
    }
  }

  Future<void> iniciarCosecha(BuildContext context) async {
    List<Map<String, dynamic>> cosechaIniciada =
        await CosechaDao().cosechaIniciada();

    if (cosechaIniciada.isEmpty) {
      var cosecha = CosechaModel(fechaInicio: DateTime.now());
      await CosechaDao().insert(cosecha);
      if (!context.mounted) return;
      await Provider.of<CosechaProvider>(context, listen: false).getIdCosecha();
      if (!context.mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const RecogidaPage()));
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Ya hay una cosecha iniciada',
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
            ),
          ),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Theme.of(context).colorScheme.onError,
        ),
      );
    }
  }

  Future<void> finalizarCosecha(
      BuildContext context, bool recogidaIniciada) async {
    peticion();
    if (!recogidaIniciada) {
      List<Map<String, dynamic>> cosechaIniciada =
          await CosechaDao().cosechaIniciada();
      if (cosechaIniciada.isNotEmpty && cosechaIniciada.length == 1) {
        var cosecha = CosechaModel(
          fechaFin: DateTime.now(),
          idCosecha: cosechaIniciada[0]['id_cosecha'],
          fechaInicio: DateTime.parse(cosechaIniciada[0]['fecha_inicio']),
        );
        // Todo: falta poner los kilos de café de la cosecha
        try {
          await CosechaDao().update(cosecha);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  'Finalización exitosa',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.surface),
                ),
              ),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: Theme.of(context).colorScheme.onError,
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  'Error al finalizar, intentelo nuevamente',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: Theme.of(context).colorScheme.onError,
            ),
          );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'No hay cosecha iniciada para finalizar',
                style: TextStyle(color: Theme.of(context).colorScheme.surface),
              ),
            ),
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: Theme.of(context).colorScheme.onError,
          ),
        );
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          content: const Center(
            child: Text(
              'Hay una recogida iniciada, Finalicela antes de cerrar la cosecha',
              style: TextStyle(color: Colors.red),
            ),
          ),
          dismissDirection: DismissDirection.up,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    }
  }

  Future<void> navegarSiCosechaIniciada(
      BuildContext context, String texto) async {
    List<Map<String, dynamic>> cosechaIniciada =
        await CosechaDao().cosechaIniciada();

    if (cosechaIniciada.isNotEmpty) {
      if (!context.mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const RecogidaPage()));
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texto)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cafeteros de Colombia'),
          titleTextStyle: const TextStyle(
            fontSize: 20,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
        ),
        drawer: Drawer(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  border: Border.all(width: 0),
/*                   boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 0.0,
                    ),
                  ], */
                ),
                child: const Center(
                  child: Text('Menú Principal',
                      style: TextStyle(fontSize: 26.0, color: Colors.white)),
                ),
              ),
              ListTile(
                title: Text('Trabajadores',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).colorScheme.secondary)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TrabajadoresPage()));
                },
              ),
              ListTile(
                title: Text('Recogidas',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).colorScheme.secondary)),
                onTap: () {
                  navegarSiCosechaIniciada(context,
                      'No hay una cosecha iniciada,\n Iniciela en el botón inferior derecho verde');
                },
              ),
              ListTile(
                title: Text('Gastos',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).colorScheme.secondary)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const GastosPage();
                  }));
                },
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondo_cafetero.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(),
          ),
        ),
        floatingActionButton:
            Stack(alignment: Alignment.bottomRight, children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: () => iniciarCosecha(context),
              tooltip: 'Empezar Cosecha',
              child: const Icon(Icons.agriculture_rounded),
            ),
          ),
          FloatingActionButton(
              heroTag: null,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () async {
                final recogidaIniciada =
                    Provider.of<RecogidaProvider>(context, listen: false)
                        .recogidaIniciada;
                await finalizarCosecha(context, recogidaIniciada);
              },
              tooltip: 'Finalizar Cosecha',
              child: const Icon(Icons.agriculture_sharp)),
        ]));
  }
}
