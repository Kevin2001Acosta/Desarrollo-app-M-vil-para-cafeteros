import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/cosecha_model.dart';

class CosechaDao {
  final database = DatabaseHelper.instance.db;

  Future<List<CosechaModel>> readAll() async {
    final data = await database.query('Cosecha');
    return data.map((e) => CosechaModel.fromJson(e)).toList();
  }

  Future<int> insert(CosechaModel cosecha) async {
    return await database.insert('cosecha', cosecha.toJson());
  }

  Future<void> update(CosechaModel cosecha) async {
    await database.update('cosecha', cosecha.toJson(),
        where: 'id_cosecha = ?', whereArgs: [cosecha.idCosecha]);
  }

  Future<void> delete(CosechaModel cosecha) async {
    await database.delete('cosecha',
        where: 'id_cosecha = ?', whereArgs: [cosecha.idCosecha]);
  }

  Future<List<CosechaModel>> cosechaIniciada() async {
    final data = await database.query('cosecha',
        where: 'fecha_fin is null', columns: ['id_cosecha', 'fecha_inicio']);
    return data.map((e) => CosechaModel.fromJson(e)).toList();
  }
}
