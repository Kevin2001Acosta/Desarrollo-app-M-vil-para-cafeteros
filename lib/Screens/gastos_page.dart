import 'package:cafetero/DataBase/Dao/gastos_dao.dart';
import 'package:cafetero/Models/gastos_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
    'Impuestos',
    'Compra de materiales'
  ];
  String? gastoActual;
  final TextEditingController valorGastoController = TextEditingController();
  int valorGasto = 0;
  DateTime selectedDate = DateTime.now();
  // rango de inicio y fin para filtrar por fecha
  DateTimeRange? selectedDates;
  // lista de gastos para filtrar por estos
  List<String> selectedGastos = [];

  // las variables para los filtros de valor
  int? valorMinGasto;
  final TextEditingController valorMinimoController = TextEditingController();
  int? valorMaxGasto;
  final TextEditingController valorMaximoController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  void registrarGasto() async {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 65,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: gastoActual,
                        items: tiposGastos.map((String gasto) {
                          return DropdownMenuItem<String>(
                              value: gasto,
                              child: Text(
                                gasto,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ));
                        }).toList(),
                        onChanged: (String? gastoNuevo) {
                          setState(() {
                            gastoActual = gastoNuevo;
                          });
                        },
                        hint: Text('Selecciona el tipo de gasto',
                            style: TextStyle(
                                fontSize: 15,
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
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
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.secondary),
                      labelText: 'Ingrese el valor del gasto',
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      hintText: "pago",
                      hintStyle: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 65,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(10.0),
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
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save_outlined, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () async {
                      if (gastoActual != null && valorGasto > 0) {
                        GastosModel gasto = GastosModel(
                          nombre: gastoActual!,
                          valor: valorGasto,
                          fecha: selectedDate,
                        );
                        await GastosDao().insert(gasto);
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.white,
                            content: Text(
                              'Gasto registrado con éxito',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 33, 85, 35)),
                            ),
                          ),
                        );
                        setState(() {
                          gastoActual = null;
                          valorGasto = 0;
                          valorGastoController.clear();
                        });
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.white,
                            content: Text(
                              'Por favor, complete todos los campos',
                              style: TextStyle(fontSize: 15, color: Colors.red),
                            ),
                          ),
                        );
                      }
                    },
                    label: const Text(
                      'Guardar',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void filtroFecha(BuildContext context) async {
    DateTimeRange? pickedPeriod = await showDateRangePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.black, //Color del header
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 131, 155, 42), //Color del header
              onPrimary: Colors.black, //Color del texto en el header
              surface: Color(0xFFC9D1B3), //Color de fondo de los items
              onSurface: Colors.black,
              background: Color.fromARGB(
                  255, 47, 51, 35), //Color del texto de los items
            ),
            buttonTheme: const ButtonThemeData(
              textTheme:
                  ButtonTextTheme.primary, //Estilo del texto del botón 'OK'
            ),
          ),
          child: child!,
        );
      },
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    setState(() {
      selectedDates = pickedPeriod;
    });
  }

  void filtroTipo() {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Wrap(
                children: tiposGastos.map((String gasto) {
                  return CheckboxListTile(
                      title: Text(gasto),
                      value: selectedGastos.contains(gasto),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedGastos.add(gasto);
                          } else {
                            selectedGastos.remove(gasto);
                          }
                        });
                      });
                }).toList(),
              );
            },
          );
        });
  }

  void filtroValor() {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            if (valorMinGasto != int.tryParse(valorMinimoController.text) ||
                valorMaxGasto != int.tryParse(valorMaximoController.text)) {
              valorMinimoController.clear();
              valorMaximoController.clear();
            }
            return Padding(
              padding: EdgeInsets.only(
                top: 30,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 65,
                        child: TextField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: valorMinimoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.secondary),
                            labelText: 'Ingrese el mínimo',
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            hintText: "Minimo",
                            hintStyle: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10, child: Text('--')),
                      SizedBox(
                        width: 180,
                        height: 65,
                        child: TextField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: valorMaximoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.secondary),
                            labelText: 'Ingrese el máximo',
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            hintText: "Máximo",
                            hintStyle: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          valorMaximoController.clear();
                          valorMinimoController.clear();
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpiar',
                            style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          valorMinGasto =
                              int.tryParse(valorMinimoController.text);
                          valorMaxGasto =
                              int.tryParse(valorMaximoController.text);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Aceptar',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GASTOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: registrarGasto,
              icon: const Icon(Icons.receipt_long_sharp),
              label:
                  const Text('Registrar gasto', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 80),
            const Text('Filtrar por: ',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            const SizedBox(height: 3),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              const SizedBox(
                  width: 110,
                  child: Text('Fecha: ', style: TextStyle(fontSize: 20))),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                width: 60,
                height: 60,
                child: IconButton(
                  onPressed: () {
                    filtroFecha(context);
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              const SizedBox(
                  width: 110,
                  child: Text('Tipo: ', style: TextStyle(fontSize: 20))),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                width: 60,
                height: 60,
                child: IconButton(
                  onPressed: filtroTipo,
                  icon: const Icon(Icons.type_specimen_outlined),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              const SizedBox(
                  width: 110,
                  child: Text('Valor: ', style: TextStyle(fontSize: 20))),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                width: 60,
                height: 60,
                child: IconButton(
                  onPressed: filtroValor,
                  icon: const Icon(Icons.monetization_on_outlined),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: () {
                  // Todo: enviar a la pagina con los filtros
                },
                icon: const Icon(Icons.content_paste_go_outlined),
                label:
                    const Text('Ver gastos', style: TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
}
