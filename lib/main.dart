import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Screens/home_page.dart';
import 'package:cafetero/provider/cosecha_provider.dart';
import 'package:cafetero/provider/recogida_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:cafetero/Screens/trabajo_recogida_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => RecogidaProvider()),
      ChangeNotifierProvider(create: (context) => CosechaProvider()),
    ],
    child: const MyApp(),
  ));
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
          primary: Color.fromARGB(255, 131, 155,
              42), // un marrón oscuro, evocando el color del café
          secondary: Color(
              0xFF6B4226), // un verde brillante, evocando el color de las hojas de café
          surface: Color(
              0xFFC9D1B3), // un verde claro, para fondos de componentes de la interfaz de usuario
          background: Color(
              0xFFE9ECE5), // un verde muy claro, para el fondo de la aplicación
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
      ),
      home: const MyHomePage(
        title: 'Cafeteros de Colombia',
      ),
    );
  }
}
