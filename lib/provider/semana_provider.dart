import 'package:cafetero/DataBase/Dao/m_semana_dao.dart';
import 'package:cafetero/Models/m_semana_model.dart';
import 'package:flutter/foundation.dart';

class SemanaProvider with ChangeNotifier {
  bool _semanaIniciada =  false;
  
  bool get semanaIniciada => _semanaIniciada;

 SemanaProvider() {
  cargarEstadoSemana();
 }

 Future <void> cargarEstadoSemana ()  async {
   List<MSemanaModel> semana = await MSemanaDao().semanaIniciada();
   _semanaIniciada =  semana.isNotEmpty;
   notifyListeners();
 }






}