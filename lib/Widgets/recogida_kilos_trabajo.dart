import 'package:cafetero/DataBase/Dao/trabaja_dao.dart';
import 'package:cafetero/DataBase/Dao/trabajador_dao.dart';
import 'package:cafetero/Models/trabaja_model.dart';
import 'package:cafetero/Models/trabajador_model.dart';
import 'package:cafetero/Widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RecogidaKilosTrabajoW extends StatefulWidget {
  final int idRecogida;
  final int precioKilo;
  final VoidCallback onTrabajoGuardado;

  const RecogidaKilosTrabajoW(
      {required this.idRecogida,
      required this.precioKilo,
      required this.onTrabajoGuardado,
      Key? key})
      : super(key: key);

  @override
  RecogidaKilosTrabajoWState createState() => RecogidaKilosTrabajoWState();
}

class RecogidaKilosTrabajoWState extends State<RecogidaKilosTrabajoW> {
  TrabajadorModel? trabajadorSeleccionado;
  List<TrabajadorModel> trabajadores =
      []; // Aquí debes cargar los trabajadores de la base de datos
  int kilosCafe = 0;
  final TextEditingController kilosCafeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final TextEditingController dropController = TextEditingController();
  VoidCallback get onTrabajoGuardado => widget.onTrabajoGuardado;

  @override
  void initState() {
    cargarTrabajadores();
    super.initState();
  }

  @override
  void dispose() {
    dropController.dispose();
    super.dispose();
  }

  Future<void> cargarTrabajadores() async {
    // Aquí debes cargar los trabajadores de la base de datos
    List<TrabajadorModel> trabajadoresDB = await TrabajadorDao().readAll();
    setState(() {
      trabajadores = trabajadoresDB;
      if (trabajadores.isNotEmpty) {
        trabajadorSeleccionado = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Elige el trabajador'),
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
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ingrese la cantidad en kg'),
              SizedBox(
                width: 230,
                child: TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: kilosCafeController,
                  onChanged: (value) {
                    setState(() {
                      kilosCafe = int.tryParse(value) ?? 0;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kilos',
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
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fecha'),
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
                              onPrimary:
                                  Colors.white, //Color del texto en el header
                              surface: Color(
                                  0xFFC9D1B3), //Color de fondo de los items
                              onSurface:
                                  Colors.black, //Color del texto de los items
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
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (trabajadorSeleccionado != null && kilosCafe > 0) {
                TrabajaModel trabajo = TrabajaModel(
                  idRecogida: widget.idRecogida,
                  idTrabajador: trabajadorSeleccionado!.id!,
                  kilosTrabajador: kilosCafe,
                  pago: widget.precioKilo * kilosCafe,
                  fecha: selectedDate,
                );
                await TrabajaDao().insert(trabajo);
                setState(() {
                  trabajadorSeleccionado = null;
                  kilosCafe = 0;
                  kilosCafeController.clear();
                });
                onTrabajoGuardado();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                      child: Text(
                        'Registro exitoso',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.surface),
                      ),
                    ),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.onError,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                      child: Text(
                        'Por favor, llena todos los campos',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
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
              FocusScope.of(context).unfocus();
            },
            child: const Text(
              'Guardar',
            ),
          ),
        ],
      );
    });
  }
}
