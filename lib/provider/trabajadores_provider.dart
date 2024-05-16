import 'package:cafetero/DataBase/Dao/trabajador_dao.dart';
import 'package:cafetero/Models/trabajador_model.dart';
import 'package:flutter/foundation.dart';

class TrabajadoresProvider with ChangeNotifier {
  final Map<String, List<TrabajadorModel>> _trabajadores = {};

  Map<String, List<TrabajadorModel>> get trabajadores => _trabajadores;

  TrabajadoresProvider() {
    cargarTrabajadores();
  }

  Future<void> cargarTrabajadores() async {
    // TODO: Cargar todos los trabajadores desde la base de datos
    var trabajadores = await TrabajadorDao().readAll();
    _trabajadores.clear();
    for (var trabajador in trabajadores) {
      if (!_trabajadores.containsKey(trabajador.nombre)) {
        _trabajadores[trabajador.nombre] = [];
      }
      _trabajadores[trabajador.nombre]!.add(trabajador);
    }
    notifyListeners();
  }

  Future<void> cargarTrabajador(TrabajadorModel trabajador) async {
    // TODO: Cargar un trabajador específico desde la base de datos
    var trabajadorCargado = await TrabajadorDao().read(trabajador);
  }

  Future<void> insertarTrabajadores(TrabajadorModel trabajador) async {
    // TODO: Insertar un nuevo trabajador en la base de datos
    await TrabajadorDao().insert(trabajador);
    cargarTrabajadores();
  }

  Future<void> actualizarTrabajadores(TrabajadorModel trabajador) async {
    // TODO: Actualizar un trabajador existente en la base de datos
    await TrabajadorDao().update(trabajador);
    cargarTrabajadores();
  }

  Future<void> borrarTrabajadores(TrabajadorModel trabajador) async {
    // TODO: Eliminar un trabajador de la base de datos
    await TrabajadorDao().delete(trabajador);
    cargarTrabajadores();
  }

  void imprimirTrabajadores() {
    _trabajadores.forEach((nombre, lista) {
      print('Nombre: $nombre');
      lista.forEach((trabajador) {
        print('  - ${trabajador.id}: ${trabajador.nombre}');
      });
    });
  }
}
