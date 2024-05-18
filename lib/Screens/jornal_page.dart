import 'package:cafetero/DataBase/Dao/m_semana_dao.dart';
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




class JornalPage extends StatefulWidget {
  const JornalPage({Key? key}) : super(key: key);

  @override
  State<JornalPage> createState() => _JornalPageState();
}

class _JornalPageState extends State<JornalPage> {
  Map<String, dynamic>? result;
  bool semanaIniciada = false;
  Map<String, List<JornalModel>> trabajos = {};
  List<JornalModel> jornales = [];
  Map<int, TrabajadorModel> trabajadoresMap = {};

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
    mostrarJornalesGuardados();
  }

  void empezarSemanaButton() async {
    final MSemanaModel semana = MSemanaModel(fechaInicio: DateTime.now());
    await MSemanaDao().insert(semana);
    await context.read<SemanaProvider>().cargarEstadoSemana();
  }

  void finalizarSemanaButton() async {
    final List<MSemanaModel> semanaActual = await MSemanaDao().semanaIniciada();
    if (semanaActual.isNotEmpty) {
      await MSemanaDao().update(
        MSemanaModel(
          idSemana: semanaActual[0].idSemana,
          fechaInicio: semanaActual[0].fechaInicio,
          fechaFin: DateTime.now(),
        ),
      );
    }
    await context.read<SemanaProvider>().cargarEstadoSemana();
  }

  Future<void> cargarTrabajadores() async {
    List<TrabajadorModel> trabajadoresDB = await TrabajadorDao().readAll();
    setState(() {
      trabajadores = trabajadoresDB;
      trabajadoresMap = {for (var t in trabajadoresDB) t.idTrabajador!: t};
      if (trabajadores.isNotEmpty) {
        trabajadorSeleccionado = null;
      }
    });
  }

  void guardarJornal() async {
    final List<MSemanaModel> semanaActual = await MSemanaDao().semanaIniciada();
    if (semanaActual.isNotEmpty && trabajadorSeleccionado != null && pago > 0 && descripcion.isNotEmpty) {
      final int? idSemana = semanaActual[0].idSemana;
      if (idSemana != null) {
        final JornalModel jornal = JornalModel(
          idTrabajador: trabajadorSeleccionado!.idTrabajador ?? 0,
          idSemana: idSemana,
          descripcion: descripcion,
          pagoTrabajador: pago,
          fecha: selectedDate,
        );
        await JornalDao().insert(jornal);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jornal guardado con éxito')),
        );
        mostrarJornalesGuardados();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo obtener el idSemana')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
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
      title: const Text("Jornal"),
    ),
    body: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
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
                        style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black, // Texto en negro
                    ),
                        onPressed: empezarSemanaButton,
                        child: Text('Iniciar Semana'),
                      ),
                    ),
                    Visibility(
                      visible: semanaIniciada,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Texto en negro
                    ),
                        onPressed: finalizarSemanaButton,
                        child: Text('Finalizar Semana'),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                // Texto "Trabajador"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Elige el trabajador'),
                          SizedBox(height: 8), 
                          Container(
                            width: 230,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: CustomDropdown(
                                items: trabajadores,
                                selectedItem: trabajadorSeleccionado,
                                onChanged: (TrabajadorModel? trabajador) {
                                  setState(() {
                                    trabajadorSeleccionado = trabajador;
                                  });
                                },
                                controller: dropController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Texto "Ingresa el valor del pago"
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pago'),
                          SizedBox(height: 8), // Espacio entre el texto y el cuadro
                          SizedBox(
                            width: 230,
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
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Ingrese el valor del pago',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Texto "Ingresa la descripción del jornal"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ingrese la descripción del jornal'),
                          SizedBox(height: 8), // Espacio entre el texto y el cuadro
                          SizedBox(
                            width: 230,
                            child: TextField(
                              controller: descripcionController,
                              onChanged: (value) {
                                setState(() {
                                  descripcion = value;
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Descripción',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Widget de fecha
                SizedBox(height: 20),
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha'), // Texto "Fecha:"
                  SizedBox(height: 8), // Espacio entre el texto y la cajita
                  Container(
                    width: 230,
                    height: 60,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
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
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
            ),
                ],
          ),

                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Texto en negro
                    ),
                  onPressed: guardarJornal,
                  child: Text('Guardar Jornal'),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}


}

