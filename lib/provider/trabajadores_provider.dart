import 'package:flutter/foundation.dart';
import 'package:cafetero/DataBase/Dao/trabajador_dao.dart';
import 'package:cafetero/Models/trabajador_model.dart';

class TrabajadoresProvider with ChangeNotifier {
  final Map<String, List<TrabajadorModel>> _trabajadores = {};
  bool isLoading = true;

  Map<String, List<TrabajadorModel>> get trabajadores => _trabajadores;

  TrabajadoresProvider() {
    cargarTrabajadores();
  }

  Future<void> cargarTrabajadores() async {
    isLoading = true;
    notifyListeners();

    var trabajadores = await TrabajadorDao().readAll();
    _trabajadores.clear();
    for (var trabajador in trabajadores) {
      if (!_trabajadores.containsKey(trabajador.nombre)) {
        _trabajadores[trabajador.nombre] = [];
      }
      _trabajadores[trabajador.nombre]!.add(trabajador);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> cargarTrabajador(TrabajadorModel trabajador) async {
    var trabajadorCargado = await TrabajadorDao().read(trabajador);
  }

  Future<void> insertarTrabajadores(TrabajadorModel trabajador) async {
    await TrabajadorDao().insert(trabajador);
    await cargarTrabajadores();
  }

  Future<void> actualizarTrabajadores(TrabajadorModel trabajador) async {
    await TrabajadorDao().update(trabajador);
    await cargarTrabajadores();
  }

  Future<void> borrarTrabajadores(TrabajadorModel trabajador) async {
    await TrabajadorDao().delete(trabajador);
    await cargarTrabajadores();
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
