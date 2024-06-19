import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cafetero/Models/jornal_model.dart';
import 'package:cafetero/DataBase/Dao/jornal_dao.dart';
import 'package:cafetero/Models/trabajador_model.dart';
import 'package:cafetero/DataBase/Dao/trabajador_dao.dart';
import 'package:intl/intl.dart';

class VerJornalesPage extends StatefulWidget {
  final int idSemana;
  const VerJornalesPage({Key? key, required this.idSemana}) : super(key: key);

  @override
  State<VerJornalesPage> createState() => _VerJornalesPage();
}

class _VerJornalesPage extends State<VerJornalesPage> {
  Map<int, TrabajadorModel> trabajadoresMap = {};
  List<TrabajadorModel> trabajadores = [];
  bool _isLoading = true;
  bool _isDescending = true;

  @override
  void initState() {
    super.initState();
    cargarTrabajadores();
  }

  Future<void> cargarTrabajadores() async {
    List<TrabajadorModel> trabajadoresDB = await TrabajadorDao().readAll();
    setState(() {
      trabajadores = trabajadoresDB;
      trabajadoresMap = {
        for (var trabajador in trabajadores) trabajador.id!: trabajador
      };
      _isLoading = false;
    });
  }
  
  Future<void> actualizarJornales(JornalModel jornal, TrabajadorModel? trabajador) async {
  final TextEditingController descripcionController = TextEditingController(text: jornal.descripcion);
  final TextEditingController pagoController = TextEditingController(text: jornal.pagoTrabajador.toString());
  final TextEditingController fechaController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(jornal.fecha));
  TrabajadorModel? trabajadorSeleccionado = trabajador;
  await showModalBottomSheet(
    elevation: 5,
    isScrollControlled: true,
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          padding: EdgeInsets.only(
            top: 30,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 50,
          ),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DropdownButtonFormField<TrabajadorModel>(
                value: trabajadorSeleccionado,
                items: trabajadores.map((trabajador) {
                  return DropdownMenuItem<TrabajadorModel>(
                    value: trabajador,
                    child: Text(trabajador.nombre),
                  );
                }).toList(),
                onChanged: (TrabajadorModel? newValue) {
                  setModalState(() {
                    trabajadorSeleccionado = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
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
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descripcionController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
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
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pagoController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  labelText: 'Pago',
                  border: OutlineInputBorder(),
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
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fechaController,
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: jornal.fecha,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Colors.black, // Color del header
                          colorScheme: const ColorScheme.light(
                            primary: Color.fromARGB(255, 131, 155, 42), // Color del header
                            onPrimary: Colors.white, // Color del texto en el header
                            surface: Color(0xFFC9D1B3), // Color de fondo de los items
                            onSurface: Colors.black, // Color del texto de los items
                          ),
                          buttonTheme: const ButtonThemeData(
                            textTheme: ButtonTextTheme.primary, // Estilo del texto del botón 'OK'
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setModalState(() {
                      fechaController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      jornal.fecha = pickedDate;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  border: OutlineInputBorder(),
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
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () async {
                    // Validar campos antes de actualizar
                     if (descripcionController.text.isEmpty) {
                      mostrarAlertDialog(context, 'Por favor, ingresa la descripción');
                      return;
                    }
                    if (pagoController.text.isEmpty) {
                      mostrarAlertDialog(context, 'Por favor, ingresa el pago');
                      return;
                    }
                    jornal.descripcion = descripcionController.text;
                    jornal.pagoTrabajador = int.tryParse(pagoController.text) ?? 0;
                    if (trabajadorSeleccionado?.id != null) {
                      jornal.idTrabajador = trabajadorSeleccionado!.id!;
                    }
                    await JornalDao().update(jornal);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: AutoSizeText(
                        "Jornal actualizado con exito",
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

                    cargarTrabajadores();
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Actualizar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
  setState(() {});
}

void mostrarAlertDialog(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Advertencia', ),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar',  style: TextStyle(color: Theme.of(context).colorScheme.surface)),
          ),
        ],
      );
    },
  );
}

  Future<void> borrarJornal(JornalModel jornal) async {
    await JornalDao().delete(jornal);
    cargarTrabajadores();
  }
  void _toggleSortOrder() {
    setState(() {
      _isDescending = !_isDescending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JORNALES EN SEMANA ACTUAL',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton.icon(
              onPressed: _toggleSortOrder,
              icon: Icon(
                _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
              ),
              label: Text(
                _isDescending
                    ? 'Ordenar descendente'
                    : 'Ordenar ascendente',
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<JornalModel>>(
              future: JornalDao().getJornalesPorSemana(widget.idSemana),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  );
                } else {
                  final jornales = snapshot.data!;
                  if (jornales.isEmpty) {
                    return const Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.black,
                          size: 25,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'No hay jornales para mostrar',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ));
                  }
                  jornales.sort((a, b) =>
                      _isDescending ? b.fecha.compareTo(a.fecha) : a.fecha.compareTo(b.fecha));
                  Map<DateTime, List<JornalModel>> groupedJornales = {};
                  for (var jornal in jornales) {
                    final date = DateTime(jornal.fecha.year, jornal.fecha.month,
                        jornal.fecha.day);
                    if (groupedJornales[date] == null) {
                      groupedJornales[date] = [];
                    }
                    groupedJornales[date]!.add(jornal);
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: groupedJornales.entries.map((entry) {
                        final date = entry.key;
                        final jornalesPorFecha = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.date_range,
                                    color: Colors.black),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    DateFormat('yyyy-MM-dd').format(date),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            ...jornalesPorFecha.map((jornal) {
                              final trabajador =
                                  trabajadoresMap[jornal.idTrabajador];
                              return _buildJornalCard(jornal, trabajador);
                            }),
                            const SizedBox(height: 20),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJornalCard(JornalModel jornal, TrabajadorModel? trabajador) {
    return Card(
      color: const Color.fromARGB(255, 205, 218, 166),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 255, 252, 252),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    trabajador?.nombre ?? "Desconocido",
                    style: const TextStyle(fontSize: 22, color: Colors.black),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.white),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, color: Colors.black),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 20),
                      children: [
                        const TextSpan(
                          text: 'Descripción: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: jornal.descripcion,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.black),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 20),
                      children: [
                        const TextSpan(
                          text: 'Pago: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: jornal.pagoTrabajador.toString(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                     actualizarJornales(jornal, trabajador);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmación'),
                          content: const Text('¿Estás seguro de eliminar este jornal?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancelar', 
                              style: TextStyle(color: Theme.of(context).colorScheme.surface),),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Eliminar', 
                              style: TextStyle(color: Theme.of(context).colorScheme.surface),),
                              onPressed: () {
                                borrarJornal(jornal);
                                Navigator.of(context).pop();
                                if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: AutoSizeText(
                                    "Jornal eliminado con exito",
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
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
