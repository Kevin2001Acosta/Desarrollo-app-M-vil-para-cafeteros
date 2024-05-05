import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/m_semana_model.dart';


class MSemanaDao {
  final database = DatabaseHelper.instance.db;

  Future<List<MSemanaModel>> readAll() async {
    final data = await database.query('M_Semana');
    return data.map((e) => MSemanaModel.fromJson(e)).toList();
  }

  Future<int> insert(MSemanaModel semana) async {
    return await database.insert('M_Semana', semana.toJson());
  }

  Future<void> update(MSemanaModel semana) async {
    await database.update('M_Semana', semana.toJson(),
        where: 'id_semana = ?', whereArgs: [semana.idSemana]);
  }

  Future<void> delete(MSemanaModel semana) async {
    await database.delete('M_Semana',
        where: 'id_semana = ?', whereArgs: [semana.idSemana]);
  }
}
