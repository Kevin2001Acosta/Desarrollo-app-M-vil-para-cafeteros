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
      trabajadoresMap = Map.fromIterable(
        trabajadores,
        key: (trabajador) => trabajador.id,
        value: (trabajador) => trabajador,
      );
      _isLoading = false;
    });
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
        title: const Text("Jornales por semana"),
        titleTextStyle: const TextStyle(fontSize: 20),
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
                _isDescending ? 'Ordenar descendente' : 'Ordenar ascendente',
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10), // Espacio entre el botón y la fecha
          Expanded(
            child: FutureBuilder<List<JornalModel>>(
              future: JornalDao().getJornalesPorSemana(widget.idSemana),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  );
                } else {
                  final jornales = snapshot.data!;
                  if (jornales.isEmpty) {
                    return const Center(child:Row(
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
                      ],));
                  }

                  jornales.sort((a, b) => _isDescending ? b.fecha.compareTo(a.fecha) : a.fecha.compareTo(b.fecha));

                  Map<DateTime, List<JornalModel>> groupedJornales = {};
                  for (var jornal in jornales) {
                    final date = DateTime(jornal.fecha.year, jornal.fecha.month, jornal.fecha.day);
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
                                const Icon(Icons.date_range, color: Colors.black),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    DateFormat('yyyy-MM-dd').format(date),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            ...jornalesPorFecha.map((jornal) {
                              final trabajador = trabajadoresMap[jornal.idTrabajador];
                              return _buildJornalCard(jornal, trabajador);
                            }).toList(),
                            const SizedBox(height: 20), // Espacio entre la Card y la siguiente fecha
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduce el margen para pegar más la Card
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
                    '${trabajador?.nombre ?? "Desconocido"}',
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
          ],
        ),
      ),
    );
  }
}








