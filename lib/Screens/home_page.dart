// ignore_for_file: prefer_const_constructors

import 'dart:ffi';
import 'dart:io';
import 'package:cafetero/DataBase/Dao/cosecha_dao.dart';
import 'package:cafetero/Models/cosecha_model.dart';
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
import 'package:rounded_background_text/rounded_background_text.dart';

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
        const SnackBar(
          content: Text('Ya hay una cosecha iniciada'),
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
        await CosechaDao().update(cosecha);
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text('Cafeteros de Colombia'),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.white),
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
            backgroundColor: Color(0xFFF5F9F3),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Container(
                    width: 217,
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Color de fondo
                    borderRadius: BorderRadius.circular(15), // Ajusta el radio según tus preferencias
                  ),
                  child: Text(
                    '¡Bienvenido, Admin!👋',
                    style: TextStyle(
                      fontSize: 19.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),  
                  accountEmail: null,
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color.fromARGB(255, 31, 31, 31), width: 1.5),
                    ),
                    child: CircleAvatar(
                      backgroundColor:  Color(0xFFF5F9F3),
                      radius: 30,
                      backgroundImage: AssetImage('assets/logo.png'), // Cambia la imagen según tus necesidades
                    ),
                  ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/fondo2.png'),
                        fit: BoxFit.cover,
                      )
                    ),
                ),
                ListTile(
                  leading: Icon(Icons.person_2_sharp),
                  title: Text('Crear Trabajador'),
                  onTap: () => {print("si")},
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.5), thickness: 1,
                ),
                ListTile(
                  leading: Icon(Icons.app_registration_rounded),
                  title: Text('Registrar Recogida',),
                  onTap: () => {navegarSiCosechaIniciada(context,'No hay una cosecha iniciada,\n Iniciela en el botón inferior derecho verde')},
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.5), thickness: 1,
                ),
                ListTile(
                  leading: Icon(Icons.money_rounded),
                  title: Text('Registrar Gastos',),
                  onTap: () => {print("si")},
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.5), thickness: 1,
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
              onPressed: () => iniciarCosecha(context),
              tooltip: 'Empezar Cosecha',
              child: const Icon(Icons.agriculture_rounded),
            ),
          ),
          FloatingActionButton(
              heroTag: null,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                final recogidaIniciada =
                    Provider.of<RecogidaProvider>(context, listen: false)
                        .recogidaIniciada;
                finalizarCosecha(context, recogidaIniciada);
              },
              tooltip: 'Finalizar Cosecha',
              child: const Icon(Icons.agriculture_sharp)),
        ]));
  }
}
