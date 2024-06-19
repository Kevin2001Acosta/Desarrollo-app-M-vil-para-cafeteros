import 'package:cafetero/DataBase/Dao/gastos_dao.dart';
import 'package:cafetero/DataBase/Dao/recogida_dao.dart';
import 'package:cafetero/DataBase/Dao/trabaja_dao.dart';
import 'package:cafetero/Models/gastos_model.dart';
import 'package:cafetero/Models/recogida_model.dart';
import 'package:cafetero/Models/trabaja_model.dart';
import 'package:cafetero/Screens/home_page.dart';
import 'package:cafetero/Screens/pagos_recogidas_page.dart';
import 'package:cafetero/Widgets/recogida_dia_trabajo.dart';
import 'package:cafetero/Widgets/recogida_kilos_trabajo.dart';
import 'package:cafetero/provider/cosecha_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cafetero/provider/recogida_provider.dart';
import 'package:cafetero/Widgets/dialogo_valores_recogida.dart';

class RecogidaPage extends StatefulWidget {
  const RecogidaPage({super.key});

  @override
  State<RecogidaPage> createState() => _RecogidaPageState();
}

enum Recogida { alDia, kiliado }

class _RecogidaPageState extends State<RecogidaPage> {
  Map<String, dynamic>? result;
  bool recogidaIniciada = false;
  int? idCosecha;
  Map<String, List<TrabajaModel>> trabajos = {};

  @override
  void initState() {
    super.initState();
    cargarTrabajos();
  }

  void cargarTrabajos() async {
    final List<TrabajaModel> trabajosDB = await TrabajaDao().trabajosActuales();
    Map<String, List<TrabajaModel>> trabajosFecha = {};
    for (var trabajo in trabajosDB) {
      if (!trabajosFecha
          .containsKey(DateFormat('yyyy-MM-dd').format(trabajo.fecha))) {
        trabajosFecha[DateFormat('yyyy-MM-dd').format(trabajo.fecha)] = [];
      }
      trabajosFecha[DateFormat('yyyy-MM-dd').format(trabajo.fecha)]!
          .add(trabajo);
    }
    setState(() {
      trabajos = trabajosFecha;
    });
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
        result = {'precioDia': 50000};
        break;
      case Recogida.kiliado:
        if (!mounted) return;
        result = await mostrarDialogoRecogida(context, Recogida.kiliado);
        // ? lo mismo que al dia pero kiliado
        break;
      case null:
        break;
    }

    if (result != null) {
      // Aquí puedes iniciar la recogida con los datos recogidos
      // llamado a bd hecho
      final jornals = result!['precioDia'] == null ? 0 : 1;
      if (!mounted) return;
      context.read<RecogidaProvider>().iniciarRecogida(RecogidaModel(
            jornal: jornals,
            idCosecha: idCosecha!,
            fechaInicio: DateTime.now(),
            precioKilo:
                jornals == 1 ? null : int.tryParse(result!['precioKilo']),
          ));
      context.read<RecogidaProvider>().cargarEstadoRecogida();
    }
  }

  void finalizarRecogida() async {
    final recogida = await RecogidaDao().recogidaIniciada();
    final sumTrabajos =
        await TrabajaDao().kilosRecogida(recogida[0].idRecogida.toString());
    if (recogida.isNotEmpty && recogida.length == 1 && sumTrabajos.isNotEmpty) {
      // Todo: si no hay trabajos en la recogida no finalizar recogida
      // Todo: preguntar si desea eliminar la recogida ya que no hay registros

      // creo una insidencia de gastos y le agrego los pagos de los trabajadores
      final GastosModel gasto = GastosModel(
          nombre: 'Recolecta de café',
          valor: sumTrabajos[0]['pagos'] as int,
          fecha: DateTime.now());
      final idGasto = await GastosDao().insert(gasto);
      final RecogidaModel recogidaFinal = RecogidaModel(
        idRecogida: recogida[0].idRecogida as int,
        fechaInicio: recogida[0].fechaInicio,
        fechaFin: DateTime.now(),
        idCosecha: recogida[0].idCosecha,
        jornal: recogida[0].jornal,
        precioKilo: recogida[0].precioKilo,
        kilosTotales: sumTrabajos[0]['kilos_totales'],
        idGastos: idGasto,
      );
      if (!mounted) return;
      context.read<RecogidaProvider>().finalizarRecogida(recogidaFinal);
      context.read<RecogidaProvider>().cargarEstadoRecogida();
    }
    setState(() {
      trabajos = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final recogidaIniciada = context.watch<RecogidaProvider>().recogidaIniciada;
    final idCosecha = context.watch<CosechaProvider>().idCosecha;
    final infoRecogida = context.watch<RecogidaProvider>().infoUltimaRecogida;
    final jornal = infoRecogida?.jornal;

    setState(() {
      this.recogidaIniciada = recogidaIniciada;
      this.idCosecha = idCosecha;
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    const MyHomePage()), // Replace HomePage with your main page
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'RECOGIDA DE CAFÉ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20.0),
                Visibility(
                  visible: recogidaIniciada,
                  child: ElevatedButton(
                    onPressed: finalizarRecogida,
                    child: const Text('Finalizar Recogida',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
                Visibility(
                  visible: !recogidaIniciada,
                  child: ElevatedButton(
                    onPressed: iniciarRecogida,
                    child: const Text('Iniciar Recogida',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 20.0),
                if (jornal == 0)
                  RecogidaKilosTrabajoW(
                      idRecogida: infoRecogida!.idRecogida as int,
                      precioKilo: infoRecogida.precioKilo as int,
                      onTrabajoGuardado: cargarTrabajos),
                if (jornal == 1)
                  RecogidaDiaTrabajoW(
                      idRecogida: infoRecogida!.idRecogida as int,
                      onTrabajoGuardado: cargarTrabajos),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).colorScheme.surface,
          onPressed: () {
            if (infoRecogida != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PagosRecogidasPage(idRecogida: infoRecogida.idRecogida!),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'No hay una cosecha seleccionada para ver recogidas.'),
                ),
              );
            }
          },
          label: const Text('Ver recogidas', style: TextStyle(fontSize: 16)),
          icon: const Icon(Icons.history_sharp),
        ),
      ),
    );
  }
}
