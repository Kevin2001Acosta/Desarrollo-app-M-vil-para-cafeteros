import 'package:cafetero/DataBase/Dao/trabaja_dao.dart';
import 'package:cafetero/DataBase/Dao/trabajador_dao.dart';
import 'package:cafetero/Models/trabaja_model.dart';
import 'package:cafetero/Models/trabajador_model.dart';
import 'package:cafetero/Widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RecogidaDiaTrabajoW extends StatefulWidget {
  final int idRecogida;
  final VoidCallback onTrabajoGuardado;

  const RecogidaDiaTrabajoW(
      {required this.idRecogida, required this.onTrabajoGuardado, super.key});

  @override
  State<RecogidaDiaTrabajoW> createState() => _RecogidaDiaTrabajoWState();
}

class _RecogidaDiaTrabajoWState extends State<RecogidaDiaTrabajoW> {
  TrabajadorModel? trabajadorSeleccionado;
  List<TrabajadorModel> trabajadores = [];
  int kilosCafe = 0;
  int pago = 0;
  final TextEditingController kilosCafeController = TextEditingController();
  final TextEditingController pagoController = TextEditingController();
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
        children: <Widget>[
          Row(
            children: [
              const Flexible(
                flex: 1,
                child: SizedBox(
                  width: 150,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Trabajador:',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: 180,
                  child: CustomDropdown(
                      items: trabajadores,
                      selectedItem: trabajadorSeleccionado,
                      onChanged: (TrabajadorModel? trabajador) {
                        setState(() {
                          trabajadorSeleccionado = trabajador;
                        });
                      },
                      controller: dropController),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 3),
              const Flexible(
                  flex: 1,
                  child: SizedBox(
                      width: 150,
                      child: Align(
                          alignment: Alignment.center,
                          child: Text('Kgs de café: ',
                              style: TextStyle(fontSize: 20))))),
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: 180,
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
                      labelText: 'Ingresa los Kgs',
                      labelStyle: TextStyle(
                        color: kilosCafeController.text.isEmpty
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 3),
              Flexible(
                  flex: 1,
                  child: Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Align(
                          alignment: Alignment.centerRight,
                          child:
                              Text('Pago:', style: TextStyle(fontSize: 20))))),
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: 180,
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
                      labelStyle: TextStyle(
                        color: pagoController.text.isEmpty
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
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
            child: Text(
              DateFormat('yyyy-MM-dd').format(selectedDate),
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (trabajadorSeleccionado != null && kilosCafe > 0 && pago > 0) {
                TrabajaModel trabajo = TrabajaModel(
                  idRecogida: widget.idRecogida,
                  idTrabajador: trabajadorSeleccionado!.id!,
                  kilosTrabajador: kilosCafe,
                  pago: pago,
                  fecha: selectedDate,
                );
                await TrabajaDao().insert(trabajo);
                setState(() {
                  trabajadorSeleccionado = null;
                  kilosCafe = 0;
                  kilosCafeController.clear();
                });
                onTrabajoGuardado();
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
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    });
  }
}
