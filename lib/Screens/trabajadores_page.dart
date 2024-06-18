import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafetero/Models/trabajador_model.dart';
import 'package:cafetero/provider/trabajadores_provider.dart';

class TrabajadoresPage extends StatefulWidget {
  const TrabajadoresPage({Key? key}) : super(key: key);

  @override
  State<TrabajadoresPage> createState() => _TrabajadoresPageState();
}

class _TrabajadoresPageState extends State<TrabajadoresPage> {
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Cargar trabajadores después de que el widget se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarTrabajadores();
    });
  }

  // TODO: Método para cargar trabajadores desde el proveedor
  void _cargarTrabajadores() async {
    await Provider.of<TrabajadoresProvider>(context, listen: false)
        .cargarTrabajadores();
  }

  // TODO: Método para agregar un nuevo trabajador
  Future<void> _addTrabajador() async {
    final String nombre = _nombreController.text;
    final trabajadoresProvider =
        Provider.of<TrabajadoresProvider>(context, listen: false);

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Por favor digita un nombre',
              style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (trabajadoresProvider.trabajadores.values
        .expand((list) => list)
        .any((trabajador) => trabajador.nombre == nombre)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('El trabajador ya existe, Por favor digita otro nombre',
              style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    await Provider.of<TrabajadoresProvider>(context, listen: false)
        .insertarTrabajadores(TrabajadorModel(nombre: nombre));
    _nombreController.clear();
    _cargarTrabajadores();
  }

  // TODO: Método para actualizar un trabajador existente
  Future<void> _updateTrabajador(int id) async {
    final String nombre = _nombreController.text;
    await Provider.of<TrabajadoresProvider>(context, listen: false)
        .actualizarTrabajadores(TrabajadorModel(id: id, nombre: nombre));
    _nombreController.clear();
    _cargarTrabajadores();
  }

  // TODO: Método para eliminar un trabajador
  Future<void> _deleteTrabajador(String nombre) async {
    final trabajadoresProvider =
        Provider.of<TrabajadoresProvider>(context, listen: false);
    if (trabajadoresProvider.trabajadores.containsKey(nombre)) {
      final int? id = trabajadoresProvider.trabajadores[nombre]!.first.id;
      await trabajadoresProvider
          .borrarTrabajadores(TrabajadorModel(id: id, nombre: nombre));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Trabajador eliminado'),
        ),
      );
      _cargarTrabajadores();
    } else {
      print('El nombre del trabajador no es válido: $nombre');
    }
  }

  // TODO: Mostrar hoja modal para agregar o actualizar trabajador
  void _showBottomSheet(int? id) async {
    final trabajadoresProvider =
        Provider.of<TrabajadoresProvider>(context, listen: false);

    // Limpiar el controlador del texto antes de mostrar la hoja modal
    _nombreController.clear();

    if (id != null) {
      final existingData = trabajadoresProvider.trabajadores.values
          .expand((list) => list)
          .firstWhere((trabajador) => trabajador.id == id);
      _nombreController.text = existingData.nombre;
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
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
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                labelText: 'Ingrese el nombre del trabajador',
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
                      color: Theme.of(context).colorScheme.secondary),
                ),
                hintText: "Nombre del trabajador",
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () async {
                  if (id == null) {
                    await _addTrabajador();
                  } else {
                    await _updateTrabajador(id);
                  }

                  _nombreController.clear();

                  Navigator.of(context).pop();
                  print("Trabajador agregado o actualizado");
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Agregar Trabajador" : "Actualizar Trabajador",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
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
    final trabajadoresProvider = Provider.of<TrabajadoresProvider>(context);
    final trabajadores = trabajadoresProvider.trabajadores;

    return Scaffold(
      appBar: AppBar(
        title: const Text("TRABAJADORES"),
        titleTextStyle:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // TODO: Mostrar indicador de carga mientras se cargan los trabajadores
      body: trabajadoresProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : trabajadores.isEmpty
              ? const Center(child: Text('No hay trabajadores disponibles'))
              : ListView.builder(
                  itemCount: trabajadores.values.expand((list) => list).length,
                  itemBuilder: (context, index) {
                    final trabajador = trabajadores.values
                        .expand((list) => list)
                        .elementAt(index);
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            trabajador.nombre,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.white,
                              onPressed: () => _showBottomSheet(trabajador.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.white,
                              onPressed: () =>
                                  _deleteTrabajador(trabajador.nombre),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.surface,
        onPressed: () => _showBottomSheet(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
