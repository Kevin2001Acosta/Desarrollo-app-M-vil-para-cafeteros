import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/trabajador_model.dart';

class TrabajadorDao {
  final database = DatabaseHelper.instance.db;

  Future<List<TrabajadorModel>> readAll() async {
    // TODO: Leer todos los trabajadores de la base de datos
    final data = await database.query('Trabajador');
    return data.map((e) => TrabajadorModel.fromJson(e)).toList();
  }

  Future<TrabajadorModel> read(TrabajadorModel trabajador) async {
    // TODO: Leer un trabajador específico de la base de datos
    final data = await database.query('Trabajador',
        where: 'id_trabajador = ?', whereArgs: [trabajador.id]);
    return TrabajadorModel.fromJson(data.first);
  }

  Future<int> insert(TrabajadorModel trabajador) async {
    // TODO: Insertar un nuevo trabajador en la base de datos
    return await database.insert('trabajador', {'nombre': trabajador.nombre});
  }

  Future<void> update(TrabajadorModel trabajador) async {
    // TODO: Actualizar un trabajador existente en la base de datos
    await database.update('trabajador', trabajador.toJson(),
        where: 'id_trabajador = ?', whereArgs: [trabajador.id]);
  }

  Future<void> delete(TrabajadorModel trabajador) async {
    // TODO: Eliminar un trabajador de la base de datos
    await database.delete('trabajador',
        where: 'id_trabajador = ?', whereArgs: [trabajador.id]);
  }
}


