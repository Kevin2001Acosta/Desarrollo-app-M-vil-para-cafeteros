import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/trabaja_model.dart';

class TrabajaDao {
  final database = DatabaseHelper.instance.db;

  Future<List<TrabajaModel>> readAll() async {
    final data = await database.query('Trabaja');
    return data.map((e) => TrabajaModel.fromJson(e)).toList();
  }

  Future<int> insert(TrabajaModel trabaja) async {
    return await database.insert('trabaja', trabaja.toJson());
  }

  Future<void> update(TrabajaModel trabaja) async {
    await database.update('trabaja', trabaja.toJson(),
        where: 'id_trabaja = ?', whereArgs: [trabaja.idTrabaja]);
  }

  Future<void> delete(TrabajaModel trabaja) async {
    await database.delete('trabaja',
        where: 'id_trabaja = ?', whereArgs: [trabaja.idTrabaja]);
  }
}
