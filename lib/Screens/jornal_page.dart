import 'package:auto_size_text/auto_size_text.dart';
import 'package:cafetero/DataBase/Dao/gastos_dao.dart';
import 'package:cafetero/DataBase/Dao/m_semana_dao.dart';
import 'package:cafetero/Models/gastos_model.dart';
import 'package:cafetero/Models/m_semana_model.dart';
import 'package:cafetero/Models/jornal_model.dart';
import 'package:cafetero/provider/semana_provider.dart';
import 'package:cafetero/DataBase/Dao/trabajador_dao.dart';
import 'package:cafetero/Models/trabajador_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafetero/Widgets/custom_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:cafetero/DataBase/Dao/jornal_dao.dart';
import 'package:cafetero/Screens/ver_jornales_page.dart';

class JornalPage extends StatefulWidget {
  const JornalPage({super.key});

  @override
  State<JornalPage> createState() => _JornalPageState();
}

class _JornalPageState extends State<JornalPage> {
  Map<String, dynamic>? result;
  bool semanaIniciada = false;
  Map<String, List<JornalModel>> trabajos = {};
  List<JornalModel> jornales = [];

  TrabajadorModel? trabajadorSeleccionado;
  List<TrabajadorModel> trabajadores = [];
  String descripcion = " ";
  int pago = 0;
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController pagoController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final TextEditingController dropController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarTrabajadores();
    //mostrarJornalesGuardados();
  }

  void empezarSemanaButton() async {
    final MSemanaModel semana = MSemanaModel(fechaInicio: DateTime.now());
    await MSemanaDao().insert(semana);
    if (!mounted) return;
    await context.read<SemanaProvider>().cargarEstadoSemana();
  }

  void finalizarSemanaButton() async {
    try {
      final List<MSemanaModel> semanaActual =
          await MSemanaDao().semanaIniciada();
      if (semanaActual.isNotEmpty) {
        final jornales =
            await JornalDao().getJornalesPorSemana(semanaActual[0].idSemana!);
        if (jornales.isEmpty) {
          if (!mounted) return;
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Eliminar semana'),
              content: const Text(
                  'La semana no tiene registros de jornales. ¿Desea eliminarla?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancelar',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.surface),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Eliminar',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.surface),
                  ),
                ),
              ],
            ),
          );

          if (shouldDelete == true) {
            final semanaParaEliminar = semanaActual[0];
            await MSemanaDao().delete(semanaParaEliminar);
            if (!mounted) return;
            await context.read<SemanaProvider>().cargarEstadoSemana();
            return;
          } else {
            return;
          }
        }
        try {
          final sumTrabajos = await JornalDao()
              .pagoSemanaTotal(semanaActual[0].idSemana.toString());
          if (!sumTrabajos.containsKey('pagos')) {
            throw Exception('No hay datos de pagos');
          }

          final GastosModel gasto = GastosModel(
            nombre: 'Jornales',
            valor: sumTrabajos['pagos'] as int,
            fecha: DateTime.now(),
          );
          final idGasto = await GastosDao().insert(gasto);
          await MSemanaDao().update(
            MSemanaModel(
              idSemana: semanaActual[0].idSemana,
              fechaInicio: semanaActual[0].fechaInicio,
              fechaFin: DateTime.now(),
              idGastos: idGasto,
            ),
          );
        } catch (e) {
          print('Error al sumar pagos: $e');
          return;
        }
      }

      if (!mounted) return;
      await context.read<SemanaProvider>().cargarEstadoSemana();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> cargarTrabajadores() async {
    List<TrabajadorModel> trabajadoresDB = await TrabajadorDao().readAll();
    setState(() {
      trabajadores = trabajadoresDB;
      if (trabajadores.isNotEmpty) {
        trabajadorSeleccionado = null;
      }
    });
  }

  void limpiarCampos() {
    trabajadorSeleccionado = null;
    pagoController.clear();
    descripcionController.clear();
    selectedDate = DateTime.now();
    setState(() {
      pago = 0;
      descripcion = '';
    });
  }

  void guardarJornal() async {
    final List<MSemanaModel> semanaActual = await MSemanaDao().semanaIniciada();
    if (semanaActual.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: AutoSizeText(
          "Debe iniciar una semana antes de guardar un jornal.",
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

      return;
    }
    if (semanaActual.isNotEmpty &&
        trabajadorSeleccionado != null &&
        pago > 0 &&
        descripcion.isNotEmpty) {
      final int? idSemana = semanaActual[0].idSemana;
      if (idSemana != null) {
        final JornalModel jornal = JornalModel(
          idTrabajador: trabajadorSeleccionado!.id!,
          idSemana: idSemana,
          descripcion: descripcion,
          pagoTrabajador: pago,
          fecha: selectedDate,
        );
        await JornalDao().insert(jornal);
        if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: AutoSizeText(
          "Registro exitoso",
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

        mostrarJornalesGuardados();
        limpiarCampos();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener el idSemana')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: AutoSizeText(
                "Por favor, llena todos los campos",
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

  Future<void> mostrarJornalesGuardados() async {
    List<JornalModel> jornalesDB = await JornalDao().readAll();
    setState(() {
      jornales = jornalesDB;
    });
  }

  @override
  Widget build(BuildContext context) {
    final semanaIniciada = context.watch<SemanaProvider>().semanaIniciada;

    setState(() {
      this.semanaIniciada = semanaIniciada;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "JORNAL",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: !semanaIniciada,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: empezarSemanaButton,
                      child: const Text('Iniciar Semana'),
                    ),
                  ),
                  Visibility(
                    visible: semanaIniciada,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: finalizarSemanaButton,
                      child: const Text('Finalizar Semana'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Texto "Trabajador"
              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Elige el trabajador:'),
                      const SizedBox(height: 8),
                      CustomDropdown(
                          items: trabajadores,
                          selectedItem: trabajadorSeleccionado,
                          onChanged: (TrabajadorModel? trabajador) {
                            setState(() {
                              trabajadorSeleccionado = trabajador;
                            });
                          },
                          controller: dropController),
                    ],
                  ),
                ],
              ),
              // Texto "Ingresa el valor del pago"
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 3),
                  const Text('Pago:'),
                  Container(
                    width: 230,
                    padding: const EdgeInsets.only(top: 4),
                    child: TextField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: pagoController,
                      onChanged: (value) {
                        setState(() {
                          pago = int.tryParse(value) ?? 0;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ingresa el pago',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Texto "Ingresa la descripción del jornal"
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Descripcion'),
                  Container(
                    width: 230,
                    padding: const EdgeInsets.only(top: 4),
                    child: TextField(
                        controller: descripcionController,
                        onChanged: (value) {
                          setState(() {
                            descripcion = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Descripción del jornal',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )),
                  ),
                ],
              ),
              // Widget de fecha
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha:'),
                  Container(
                    width: 230,
                    height: 65,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Colors.black, //Color del header
                                colorScheme: const ColorScheme.light(
                                  primary: Color.fromARGB(
                                      255, 131, 155, 42), //Color del header
                                  onPrimary: Colors
                                      .white, //Color del texto en el header
                                  surface: Color(
                                      0xFFC9D1B3), //Color de fondo de los items
                                  onSurface: Colors
                                      .black, //Color del texto de los items
                                ),
                                buttonTheme: const ButtonThemeData(
                                  textTheme: ButtonTextTheme
                                      .primary, //Estilo del texto del botón 'OK'
                                ),
                              ),
                              child: child!,
                            );
                          },
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //Boton guardar
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: guardarJornal,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.surface,
        onPressed: () async {
          // ! codigo para pruebas de pagina de pago jornales
          final List<MSemanaModel> semanaActual =
              await MSemanaDao().semanaIniciada();
          if (semanaActual.isNotEmpty) {
            final int id = semanaActual[0].idSemana!;
            if (!context.mounted) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerJornalesPage(idSemana: id)));
          } else {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: AutoSizeText(
                      "No hay una semana iniciada",
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
        },
        label: const Text('Ver jornal', style: TextStyle(fontSize: 16)),
        icon: const Icon(Icons.history_sharp),
      ),
    );
  }
}
