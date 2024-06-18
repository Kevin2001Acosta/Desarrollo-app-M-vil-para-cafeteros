import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Screens/home_page.dart';
import 'package:cafetero/provider/cosecha_provider.dart';
import 'package:cafetero/provider/recogida_provider.dart';
import 'package:cafetero/provider/semana_provider.dart';
import 'package:cafetero/provider/trabajadores_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:cafetero/Screens/trabajo_recogida_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecogidaProvider()),
        ChangeNotifierProvider(create: (context) => CosechaProvider()),
        ChangeNotifierProvider(create: (context) => TrabajadoresProvider()),
        ChangeNotifierProvider(create: (context) => SemanaProvider()),
      ],
      child:
          const MyApp(), // Asegúrate de definir y usar tu widget principal aquí
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Colors.white,
          /* Color.fromARGB(255, 131, 155,
              42), */ // un verde brillante, evocando el color del café
          surfaceVariant: Color(0xFFC9D1B3),
          secondary: Color(
              0xFF6B4226), // un marron oscuro, evocando el color de las hojas de café
          surface: Color.fromARGB(255, 131, 155, 42),
          /*  Color(
              0xFFC9D1B3), */ // un verde claro, para fondos de componentes de la interfaz de usuario
          background: Color.fromARGB(255, 221, 231,
              234), // un Azul muy claro, para el fondo de la aplicación
          error: Colors.red, // rojo para errores
          onPrimary: Colors.white, // texto e iconos sobre el color primario
          onSecondary: Colors.black, // texto e iconos sobre el color secundario
          onSurface:
              Colors.black, // texto e iconos sobre el color de la superficie
          onBackground: Color.fromARGB(
              255, 20, 5, 5), // texto e iconos sobre el color de fondo
          onError: Colors.white, // texto e iconos sobre el color de error
          brightness: Brightness.light, // luminosidad general del tema
        ),
        cardTheme: const CardTheme(
          color: Color.fromARGB(255, 131, 155, 42),
          shadowColor: Color.fromARGB(255, 38, 98, 107), 
          elevation: 10,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const MyHomePage(),
    );
  }
}
