import 'package:cafetero/DataBase/Dao/recogida_dao.dart';
import 'package:cafetero/Models/recogida_model.dart';
import 'package:cafetero/provider/cosecha_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafetero/provider/recogida_provider.dart';
import 'package:cafetero/Widgets/dialogo_valores_recogida.dart';

class RecogidaPage extends StatefulWidget {
  const RecogidaPage({Key? key}) : super(key: key);

  @override
  State<RecogidaPage> createState() => _RecogidaPageState();
}

enum Recogida { alDia, kiliado }

class _RecogidaPageState extends State<RecogidaPage> {
  Map<String, dynamic>? result;
  bool recogidaIniciada = false;
  int? idCosecha;

  @override
  void initState() {
    super.initState();
    print('$recogidaIniciada init');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void iniciarRecogida() async {
    if (idCosecha == null) {
      // Muestra un mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No se puede iniciar la recogida sin una cosecha seleccionada')),
      );
      return;
    }

    final sol = await showDialog<Recogida>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Iniciar Recogida'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, Recogida.alDia);
              },
              child: Text(
                'Al Dia',
                style: TextStyle(fontSize: 20.0, color: Colors.green.shade800),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, Recogida.kiliado);
              },
              child: Text(
                'Kiliado',
                style: TextStyle(fontSize: 20.0, color: Colors.green.shade800),
              ),
            ),
          ],
        );
      },
    );
    switch (sol) {
      case Recogida.alDia:
        if (!context.mounted) return;
        result = await mostrarDialogoRecogida(context, Recogida.alDia);
        // ? puedo hacer que aquí mismo se cree otro dialogo para ingresar el precio del dia?
        break;
      case Recogida.kiliado:
        if (!context.mounted) return;
        result = await mostrarDialogoRecogida(context, Recogida.kiliado);
        // ? lo mismo que al dia pero kiliado
        break;
      case null:
        // ! cancelar el dialogo y no hacer nada
        break;
    }
    // ? como hago para que se cree la recogida como yo quiero.

    if (result != null) {
      // Aquí puedes iniciar la recogida con los datos recogidos
      // llamado a bd hecho
      if (!context.mounted) return;
      context.read<RecogidaProvider>().iniciarRecogida(RecogidaModel(
            jornal: 0,
            idCosecha: idCosecha!,
            fechaInicio: DateTime.now(),
            precioKilo: 800,
          ));
    }
  }

  void finalizarRecogida() async {
    final recogida = await RecogidaDao().recogidaIniciada();
    if (recogida.isNotEmpty && recogida.length == 1) {
      if (!context.mounted) return;
      context.read<RecogidaProvider>().finalizarRecogida(RecogidaModel(
            idRecogida: recogida[0]['id_recogida'],
            fechaInicio: DateTime.parse(recogida[0]['fecha_inicio'] as String),
            fechaFin: DateTime.now(),
            idCosecha: recogida[0]['id_cosecha'] as int,
            jornal: 0,
            precioKilo: recogida[0]['precio_kilo'] as int,
            // Todo: Falta calcular y enviar los kilos totales recogidos
          ));
    }
    print(recogidaIniciada);
    print(recogida.length);
  }

  @override
  Widget build(BuildContext context) {
    final recogidaIniciada = context.watch<RecogidaProvider>().recogidaIniciada;
    final idCosecha = context.watch<CosechaProvider>().idCosecha;
    print('$recogidaIniciada build');
    print('$idCosecha build');

    setState(() {
      this.recogidaIniciada = recogidaIniciada;
      this.idCosecha = idCosecha;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recogida de café',
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            recogidaIniciada
                ? ElevatedButton(
                    onPressed: finalizarRecogida,
                    child: Text('Finalizar Recogida',
                        style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSecondary)),
                  )
                : ElevatedButton(
                    onPressed: iniciarRecogida,
                    child: Text('Iniciar Recogida',
                        style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSecondary)),
                  ),
          ],
        ),
      ),
    );
  }
}
