import 'package:cafetero/Models/cosecha_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cafetero/DataBase/Dao/cosecha_dao.dart';
//import 'package:cafetero/Models/cosecha_model.dart';

class CosechaProvider extends ChangeNotifier {
  int? _idCosecha;

  int? get idCosecha => _idCosecha;

  CosechaProvider() {
    getIdCosecha();
    notifyListeners();
  }

  Future<void> getIdCosecha() async {
    List<CosechaModel> cosechaIniciada = await CosechaDao().cosechaIniciada();
    if (cosechaIniciada.isNotEmpty && cosechaIniciada.length == 1) {
      _idCosecha = cosechaIniciada[0].idCosecha;
    } else {
      _idCosecha = null;
    }
    notifyListeners();
  }
}
