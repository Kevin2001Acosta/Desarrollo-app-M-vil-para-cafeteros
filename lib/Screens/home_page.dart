import 'dart:io';
import 'package:cafetero/DataBase/Dao/cosecha_dao.dart';
import 'package:cafetero/DataBase/Dao/gastos_dao.dart';
import 'package:cafetero/DataBase/Dao/recogida_dao.dart';
import 'package:cafetero/Models/cosecha_model.dart';
import 'package:cafetero/Screens/dash_board_page.dart';
import 'package:cafetero/Screens/gastos_page.dart';
import 'package:cafetero/Screens/trabajadores_page.dart';
import 'package:cafetero/Screens/trabajo_recogida_page.dart';
import 'package:cafetero/Screens/jornal_page.dart';
import 'package:cafetero/provider/cosecha_provider.dart';
import 'package:cafetero/provider/recogida_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:cafetero/Screens/vista_cosecha_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cafetero/Screens/vista_jornales_semana_page.dart';
import 'package:cafetero/Screens/precio_cafe_page.dart';


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
    List<CosechaModel> cosechaIniciada = await CosechaDao().cosechaIniciada();

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: AutoSizeText(
          "Ya hay una cosecha iniciada",
          style: const TextStyle(
            color: Colors.white,),
            maxLines: 3,
            minFontSize: 20.0,
            maxFontSize: 25.0,
            textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
      ));

    }
  }

  Future<void> finalizarCosecha(
      BuildContext context, bool recogidaIniciada) async {
    peticion();
    bool debeCancelar = false;
    Map<String, dynamic> kilos = {};
    if (!recogidaIniciada) {
      List<CosechaModel> cosechaIniciada = await CosechaDao().cosechaIniciada();
      if (cosechaIniciada.isNotEmpty && cosechaIniciada.length == 1) {
        try {
          kilos = await RecogidaDao()
              .kilosCosecha(cosechaIniciada[0].idCosecha.toString());
        } catch (e) {
          if (!context.mounted) return;
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Cosecha sin registros'),
                content: Text(
                  '''La cosecha no tiene registros, presione aceptar si desea eliminar la cosecha, si no eliminas la cosecha debes ingresar datos por lo menos en una recogida''',
                  style: TextStyle(color: Colors.deepOrange.shade300),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancelar',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                    onPressed: () {
                      debeCancelar = true;
                      Navigator.of(context).pop(); // Cierra el diálogo
                    },
                  ),
                  TextButton(
                    child: Text('Aceptar',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                    onPressed: () async {
                      await CosechaDao().delete(cosechaIniciada[0]);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: AutoSizeText(
                          "Cosecha eliminada exitosamente",
                          style: const TextStyle(
                            color: Colors.white,
                            ),
                            maxLines: 3,
                            minFontSize: 20.0,
                            maxFontSize: 25.0,
                            textAlign: TextAlign.center,
                            ),
                            backgroundColor: Color.fromARGB(255, 131, 155, 42),
                            duration: Duration(seconds: 3),
                      ));
                      debeCancelar = true;
                      Navigator.of(context).pop(); // Cierra el diálogo
                    },
                  ),
                ],
              );
            },
          );
        }
        if (debeCancelar) {
          return;
        }
        var cosecha = CosechaModel(
          fechaFin: DateTime.now(),
          idCosecha: cosechaIniciada[0].idCosecha,
          fechaInicio: cosechaIniciada[0].fechaInicio,
          kilosTotales: kilos['kilos_totales'] as int,
        );
        // Todo: falta verificar que los kilos se están poniendo bien
        try {
          await CosechaDao().update(cosecha);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: AutoSizeText(
              "Finalización exitosa",
              style: const TextStyle(
                color: Colors.white,
                ),
                maxLines: 3,
                minFontSize: 20.0,
                maxFontSize: 25.0,
                textAlign: TextAlign.center,
                ),
                backgroundColor: Color.fromARGB(255, 131, 155, 42),
                duration: Duration(seconds: 3),
          ));

        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: AutoSizeText(
              "Error al finalizar, intentelo de nuevo",
              style: const TextStyle(
                color: Colors.white,),
                maxLines: 3,
                minFontSize: 20.0,
                maxFontSize: 25.0,
                textAlign: TextAlign.center,
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
          ));
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: AutoSizeText(
            "No hay consecha inicializada para finalizar",
            style: const TextStyle(
              color: Colors.white,),
              maxLines: 3,
              minFontSize: 20.0,
              maxFontSize: 25.0,
              textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
        ));
      }
    } else {
      if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: AutoSizeText(
                "Hay una recogida iniciada, Finalicela antes de cerrar la cosecha",
                style: const TextStyle(
                  color: Colors.white,),
                  maxLines: 3,
                  minFontSize: 20.0,
                  maxFontSize: 25.0,
                  textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
            ));
    }
  }

  Future<void> navegarSiCosechaIniciada(
      BuildContext context, String texto) async {
    List<CosechaModel> cosechaIniciada = await CosechaDao().cosechaIniciada();

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
          title: const Text(
            'CAFETEROS DE COLOMBIA',
          ),
          centerTitle: true,
          titleTextStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          backgroundColor: const Color.fromRGBO(226, 234, 223, 1),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: MediaQuery(
                  data: MediaQuery.of(context),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.03,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 185, 192, 164)
                          .withOpacity(0.7), // Color de fondo
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: AutoSizeText(
                        '¡Bienvenido, Admin! 👋🏽',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        minFontSize: 12.0,
                        maxFontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                accountEmail: null,
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color.fromARGB(255, 69, 87, 10),
                        width: 2.0),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFFF5F9F3),
                    radius: 30,
                    backgroundImage: AssetImage(
                        'assets/logo.png'), // Cambia la imagen según tus necesidades
                  ),
                ),
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/fondo2.png'),
                  fit: BoxFit.cover,
                )),
              ),
              ListTile(
                leading: const Icon(Icons.perm_identity_outlined, size: 25),
                title: const Text('Trabajador',
                    style: TextStyle(
                      fontSize: 17.0,
                    )),
                onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TrabajadoresPage()))
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(Icons.shopping_basket_outlined, size: 25),
                title: const Text('Recogida', style: TextStyle(fontSize: 17.0)),
                onTap: () => {
                  navegarSiCosechaIniciada(context,
                      'No hay una cosecha iniciada,\n Iniciela en el botón inferior derecho verde')
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(
                  Icons.receipt_long_sharp,
                  size: 25,
                ),
                title: const Text('Gastos', style: TextStyle(fontSize: 17.0)),
                onTap: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const GastosPage();
                  }))
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(Icons.view_timeline_outlined, size: 25),
                title: const Text('Jornal',
                    style: TextStyle(
                      fontSize: 17.0,
                    )),
                onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const JornalPage()))
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(
                  Icons.view_list_outlined,
                  size: 25,
                ),
                title: const Text('Vista Cosecha',
                    style: TextStyle(fontSize: 17.0)),
                onTap: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const PaginaCosechas();
                  }))
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(
                  Icons.view_list_outlined,
                  size: 25,
                ),
                title: const Text('Vista Jornal Semana',
                    style: TextStyle(fontSize: 17.0)),
                onTap: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const PaginaSemanaJornal();
                  }))
                },
              ),Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
              ),
              ListTile(
                leading: Icon(
                  Icons.coffee,
                  size: 25,
                ),
                title: Text('Precio Actual del Café', style: TextStyle(fontSize: 17.0)),
                onTap: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PrecioCafe();
                  }))
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(
                  Icons.dashboard_outlined,
                  size: 25,
                ),
                title:
                    const Text('Dashboard', style: TextStyle(fontSize: 17.0)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const DashboardPage(
                      year: 2024,
                    );
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
            child: FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: () => iniciarCosecha(context),
              tooltip: 'Empezar Cosecha',
              label: Text('Empezar Cosecha'), 
              icon: Icon(Icons.agriculture_rounded), 
            ),
            
          ),
          FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () async {
                final recogidaIniciada =
                    Provider.of<RecogidaProvider>(context, listen: false)
                        .recogidaIniciada;
                await finalizarCosecha(context, recogidaIniciada);
              },
              tooltip: 'Finalizar Cosecha',
              label: Text('Finalizar Cosecha'), 
              icon: Icon(Icons.agriculture_rounded),  
              ),
        ]));
  }
}
