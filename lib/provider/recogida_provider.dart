import 'package:cafetero/DataBase/Dao/recogida_dao.dart';
import 'package:cafetero/Models/recogida_model.dart';
import 'package:flutter/foundation.dart';

class RecogidaProvider with ChangeNotifier {
  bool _recogidaIniciada = false;

  bool get recogidaIniciada => _recogidaIniciada;

  RecogidaProvider() {
    cargarEstadoRecogida();
  }

  Future<void> cargarEstadoRecogida() async {
    var inicio = await RecogidaDao().recogidaIniciada();
    _recogidaIniciada = inicio.isNotEmpty;
    notifyListeners();
  }

  Future<void> iniciarRecogida(RecogidaModel recogida) async {
    await RecogidaDao().insert(recogida);
    _recogidaIniciada = true;
    notifyListeners();
  }

  Future<void> finalizarRecogida(RecogidaModel recogida) async {
    await RecogidaDao().update(recogida);
    _recogidaIniciada = false;
    notifyListeners();
  }
}
