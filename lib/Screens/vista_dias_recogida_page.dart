import 'package:flutter/material.dart';
import 'package:cafetero/DataBase/Dao/trabaja_dao.dart';

class VistaDiasRecogidaPage extends StatefulWidget {
  final int? idRecogida;

  const VistaDiasRecogidaPage({Key? key, required this.idRecogida}) : super(key: key);

  @override
  State<VistaDiasRecogidaPage> createState() => _VistaDiasRecogidaPageState();
}

class _VistaDiasRecogidaPageState extends State<VistaDiasRecogidaPage> {
  bool _isLoading = true;
  bool _isDescending = true;
  Map<String, dynamic> _datosRecogida = {};

  @override
  void initState() {
    super.initState();
    cargarDatosRecogida();
  }

  Future<void> cargarDatosRecogida() async {
    try {
      final datos = await TrabajaDao().getDatosPorRecogida(widget.idRecogida);
      setState(() {
        _datosRecogida = datos;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cargar los datos: $error'),
      ));
    }
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
        title: const Text(
          'JORNALES EN SEMANA ACTUAL',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                  child: _datosRecogida.isEmpty
                      ? const Center(
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
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: _buildJornalList(),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildJornalList() {
    List<MapEntry<String, dynamic>> entries = _datosRecogida.entries.toList();

    entries.sort((a, b) {
      if (_isDescending) {
        return b.key.compareTo(a.key);
      } else {
        return a.key.compareTo(b.key);
      }
    });

    return entries.map((entry) {
      final nombre = entry.key;
      final data = entry.value;
      return _buildJornalCard(nombre, data);
    }).toList();
  }

  Widget _buildJornalCard(String nombre, Map<String, dynamic> data) {
    return Card(
      color: const Color.fromARGB(255, 205, 218, 166),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5), // Reduce el margen para pegar más la Card
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
                    nombre,
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
                const Icon(Icons.scale, color: Colors.black),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 20),
                      children: [
                        const TextSpan(
                          text: 'Kilos Recogidos: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: data['kilos_trabajador'].toString(),
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
                          text: data['pago'].toString(),
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
