import 'package:cafetero/DataBase/Dao/gastos_dao.dart';
import 'package:cafetero/Models/gastos_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class GastosPage extends StatefulWidget {
  const GastosPage({super.key});

  @override
  State<GastosPage> createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  static const List<String> tiposGastos = [
    'Compra de abono',
    'Transporte',
    'Servicios',
    'Beneficio',
    'Recolecta de café',
    'Impuestos',
    'Compra de materiales'
  ];
  String? gastoActual;
  final TextEditingController valorGastoController = TextEditingController();
  int valorGasto = 0;
  DateTime selectedDate = DateTime.now();
  Map<String, List<GastosModel>> gastos = {};

  @override
  void initState() {
    super.initState();
    cargarGastos();
  }

  Future<void> cargarGastos() async {
    await initializeDateFormatting('es_ES', null);

    List<GastosModel> gastosDB = await GastosDao().currentYear();
    Map<String, List<GastosModel>> gastosMes = {};
    for (var gasto in gastosDB) {
      String mes = DateFormat('MMMM', 'es_ES').format(gasto.fecha);
      if (!gastosMes.containsKey(mes)) {
        gastosMes[mes] = [];
      }
      gastosMes[mes]!.add(gasto);
    }
    setState(() {
      gastos = gastosMes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            SizedBox(
              width: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Elige el tipo de gasto'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    width: 230,
                    height: 60,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: gastoActual,
                        items: tiposGastos.map((String gasto) {
                          return DropdownMenuItem<String>(
                              value: gasto,
                              child: Text(
                                gasto,
                                style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ));
                        }).toList(),
                        onChanged: (String? gastoNuevo) {
                          setState(() {
                            gastoActual = gastoNuevo;
                          });
                        },
                        hint: Text('Selecciona',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ingresa el valor del gasto'),
                  SizedBox(
                    width: 230,
                    child: TextField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: valorGastoController,
                      onChanged: (value) {
                        setState(() {
                          valorGasto = int.tryParse(value) ?? 0;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '\$',
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (gastoActual != null && valorGasto > 0) {
                  GastosModel gasto = GastosModel(
                    nombre: gastoActual!,
                    valor: valorGasto,
                    fecha: selectedDate,
                  );
                  await GastosDao().insert(gasto);
                  setState(() {
                    gastoActual = null;
                    valorGasto = 0;
                    valorGastoController.clear();
                  });
                  cargarGastos();
                }
              },
              child: Text(
                'Guardar',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
