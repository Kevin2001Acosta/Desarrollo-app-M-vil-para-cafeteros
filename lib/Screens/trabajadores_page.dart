import 'package:flutter/material.dart';
import 'package:cafetero/Models/trabajador_model.dart';
import 'package:cafetero/provider/trabajadores_provider.dart';

class TrabajadoresPage extends StatefulWidget {
  const TrabajadoresPage({Key? key}) : super(key: key);

  @override
  State<TrabajadoresPage> createState() => _TrabajadoresPageState();
}

class _TrabajadoresPageState extends State<TrabajadoresPage> {
  Map<String, List<TrabajadorModel>> trabajadores = {};
  bool _isLoading = true;
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarTrabajadores();
  }

  // TODO: Cargar los trabajadores desde el proveedor al iniciar la página
  void _cargarTrabajadores() async {
    await TrabajadoresProvider().cargarTrabajadores();

    setState(() {
      trabajadores = TrabajadoresProvider().trabajadores;
      _isLoading = false;
      TrabajadoresProvider().imprimirTrabajadores();
    });
  }

  // TODO: Agregar un nuevo trabajador
  Future<void> _addTrabajador() async {
    final String nombre = _nombreController.text;
    await TrabajadoresProvider()
        .insertarTrabajadores(TrabajadorModel(nombre: nombre));

    print(nombre);

    _cargarTrabajadores();
  }

  // TODO: Actualizar un trabajador existente
  Future<void> _updateTrabajador(int id) async {
    final String nombre = _nombreController.text;
    await TrabajadoresProvider()
        .actualizarTrabajadores(TrabajadorModel(id: id, nombre: nombre));
    _cargarTrabajadores();
  }

  // TODO: Eliminar un trabajador
  Future<void> _deleteTrabajador(String nombre) async {
    if (trabajadores.containsKey(nombre)) {
      final int? id = trabajadores[nombre]!
          .first
          .id; // Obtener el ID del primer trabajador con ese nombre
      await TrabajadoresProvider()
          .borrarTrabajadores(TrabajadorModel(id: id, nombre: nombre));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Trabajador eliminado')));
      _cargarTrabajadores();
    } else {
      print('El nombre del trabajador no es válido: $nombre');
    }
  }

  void _showBottomSheet(String? id) async {
    if (id != null) {
      final existingData = trabajadores[id]!;
      _nombreController.text = existingData.first.nombre;
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Ingrese el nombre del trabajador',
                border: OutlineInputBorder(),
                hintText: "Nombre del trabajador",
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addTrabajador();
                  } else {
                    await _updateTrabajador(int.parse(id));
                  }

                  _nombreController.text = "";

                  // Ocultar la hoja inferior
                  Navigator.of(context).pop();
                  print("Trabajador agregado");
                  print(trabajadores.length);
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Agregar Trabajador" : "Actualizar Trabajador",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Trabajadores"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: trabajadores.length,
              itemBuilder: (context, index) {
                final id = trabajadores.keys.elementAt(index);
                return Card(
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          id,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      // TODO: Agregar funcionalidad de actualización y eliminación al tocar el elemento de la lista
                      onTap: () => _showBottomSheet(id),
                      onLongPress: () => _deleteTrabajador(id),
                    ));
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
