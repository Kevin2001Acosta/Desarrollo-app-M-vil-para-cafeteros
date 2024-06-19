import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/gastos_model.dart';
import 'package:intl/intl.dart';

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
    await database
        .delete('Gastos', where: 'id_gastos = ?', whereArgs: [gasto.idGastos]);
  }

  Future<List<GastosModel>> currentYear() async {
    final year = DateTime.now().year;
    final firstDayOfYear = DateTime(year);
    final data = await database.query('Gastos',
        where: 'fecha >= ?',
        whereArgs: [DateFormat('yyyy-MM-dd').format(firstDayOfYear)]);
    return data.map((e) => GastosModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getGastosbyYear(String year) async {
    final data = await database.rawQuery('''
    SELECT strftime('%m', fecha) as mes, SUM(valor) as costo
    FROM Gastos
    WHERE strftime('%Y', fecha) = ?
    GROUP BY mes
    ORDER BY mes
  ''', [year]);
    return data;
  }
}
