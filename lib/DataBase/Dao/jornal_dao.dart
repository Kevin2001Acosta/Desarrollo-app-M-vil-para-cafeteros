import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/jornal_model.dart';

class JornalDao {
  final database = DatabaseHelper.instance.db;

  Future<List<JornalModel>> readAll() async {
    final data = await database.query('Jornal');
    return data.map((e) => JornalModel.fromJson(e)).toList();
  }

  Future<int> insert(JornalModel jornal) async {
    return await database.insert('Jornal', jornal.toJson());
  }

  Future<void> update(JornalModel jornal) async {
    await database.update('Jornal', jornal.toJson(),
        where: 'id_jornal = ?', whereArgs: [jornal.idJornal]);
  }

  Future<void> delete(JornalModel jornal) async {
    await database
        .delete('Jornal', where: 'id_jornal = ?', whereArgs: [jornal.idJornal]);
  }

  Future<List<JornalModel>> getJornalesPorSemana(int idSemana) async {
    final data = await database
        .query('Jornal', where: 'id_semana = ?', whereArgs: [idSemana]);
    return data.map((e) => JornalModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> pagoSemanaTotal(String id) async {
    final data = await database.rawQuery('''
    SELECT id_semana, SUM(pago_trabajador) AS pagos
    FROM jornal
    GROUP BY id_semana
    HAVING id_semana = ?
  ''', [id]);
    if (data.isNotEmpty) {
      return data.first;
    } else {
      throw Exception('No data found for id: $id');
    }
  }
}
