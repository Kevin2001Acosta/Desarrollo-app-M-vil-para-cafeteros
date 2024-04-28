import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/trabajador_model.dart';

class TrabajadorDao {
  final database = DatabaseHelper.instance.db;

  Future<List<TrabajadorModel>> readAll() async {
    final data = await database.query('Trabajador');
    return data.map((e) => TrabajadorModel.fromJson(e)).toList();
  }

  Future<int> insert(TrabajadorModel trabajador) async {
    return await database.insert('trabajador', {'nombre': trabajador.nombre});
  }

  Future<void> update(TrabajadorModel trabajador) async {
    await database.update('trabajador', trabajador.toJson(),
        where: 'id_trabajador = ?', whereArgs: [trabajador.idTrabajador]);
  }

  Future<void> delete(TrabajadorModel trabajador) async {
    await database.delete('trabajador',
        where: 'id_trabajador = ?', whereArgs: [trabajador.idTrabajador]);
  }
}
