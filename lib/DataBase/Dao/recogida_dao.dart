import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/recogida_model.dart';

class RecogidaDao {
  final database = DatabaseHelper.instance.db;

  Future<List<RecogidaModel>> readAll() async {
    final data = await database.query('Recogida');
    return data.map((e) => RecogidaModel.fromJson(e)).toList();
  }

  Future<int> insert(RecogidaModel recogida) async {
    return await database.insert('recogida', recogida.toJson());
  }

  Future<void> update(RecogidaModel recogida) async {
    await database.update('recogida', recogida.toJson(),
        where: 'id_recogida = ?', whereArgs: [recogida.idRecogida]);
  }

  Future<void> delete(RecogidaModel recogida) async {
    await database.delete('recogida',
        where: 'id_recogida = ?', whereArgs: [recogida.idRecogida]);
  }

  Future<List<RecogidaModel>> recogidaIniciada() async {
    final data = await database.query('recogida', where: 'fecha_fin is null');
    return data.map((e) => RecogidaModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> kilosCosecha(String id) async {
    final data = await database.rawQuery('''
    SELECT id_cosecha, SUM(kilos_totales) AS kilos_totales
    FROM Recogida
    GROUP BY id_cosecha
    HAVING id_cosecha = ?
  ''', [id]);
    if (data.isNotEmpty) {
      return data.first;
    } else {
      throw Exception('No data found for id: $id');
    }
  }
}
