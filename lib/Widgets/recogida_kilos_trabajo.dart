import 'package:cafetero/DataBase/Dao/trabajador_dao.dart';
import 'package:cafetero/Models/trabajador_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecogidaKilosTrabajoW extends StatefulWidget {
  final int idRecogida;

  const RecogidaKilosTrabajoW({required this.idRecogida, Key? key})
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
  final TextEditingController dropoController = TextEditingController();

  @override
  void initState() {
    cargarTrabajadores();
    super.initState();
  }

  @override
  void dispose() {
    dropoController.dispose();
    super.dispose();
  }

  Future<void> cargarTrabajadores() async {
    // Aquí debes cargar los trabajadores de la base de datos
    List<TrabajadorModel> trabajadoresDB = await TrabajadorDao().readAll();
    setState(() {
      trabajadores = trabajadoresDB;
      if (trabajadores.isNotEmpty) {
        trabajadorSeleccionado = trabajadores[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Flexible(
              flex: 1,
              child: SizedBox(
                width: 150,
                child: Text(
                  'Trabajador:',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<TrabajadorModel>(
                  isExpanded: true,
                  value: trabajadorSeleccionado,
                  items: trabajadores.map((TrabajadorModel trabajador) {
                    return DropdownMenuItem<TrabajadorModel>(
                        value: trabajador,
                        child: Text(
                          trabajador.nombre,
                          style: const TextStyle(fontSize: 14),
                        ));
                  }).toList(),
                  onChanged: (TrabajadorModel? nuevoTrabajador) {
                    setState(() {
                      trabajadorSeleccionado = nuevoTrabajador;
                    });
                  },
                  hint: Text('Selecciona un trabajador',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface)),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Flexible(
                flex: 1,
                child: SizedBox(
                    width: 150,
                    child:
                        Text('Kgs de café: ', style: TextStyle(fontSize: 20)))),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 220,
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
                    labelText: 'Ingresa el número de Kgs',
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
        const SizedBox(
          height: 20,
        ),
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
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Aquí puedes guardar los datos en la base de datos
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
