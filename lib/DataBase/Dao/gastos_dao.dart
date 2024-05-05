import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/gastos_model.dart';


class GastosDao {
  final database = DatabaseHelper.instance.db;

  Future<List<GastosModel>> readAll() async {
    final data = await database.query('Gastos');
    return data.map((e) => GastosModel.fromJson(e)).toList();
  }

  Future<int> insert(GastosModel gasto) async {
    return await database.insert('Gastos', gasto.toJson());
  }

  Future<void> update(GastosModel gasto) async {
    await database.update('Gastos', gasto.toJson(),
        where: 'id_gastos = ?', whereArgs: [gasto.idGastos]);
  }

  Future<void> delete(GastosModel gasto) async {
    await database.delete('Gastos',
        where: 'id_gastos = ?', whereArgs: [gasto.idGastos]);
  }
}
