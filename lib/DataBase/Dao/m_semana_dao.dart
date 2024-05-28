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

  Future<List<MSemanaModel>> semanaIniciada() async {
    final data = await database.query('M_Semana', where: 'fecha_fin is null');
    return data.map((e) => MSemanaModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> pagosSemana(int id) {
    return database.rawQuery('''
            SELECT Trabajador.id_trabajador, Trabajador.nombre, SUM(Jornal.pago_trabajador) AS pago_total,count(*) as jornales
            FROM M_Semana
            INNER JOIN Jornal ON M_Semana.id_semana = Jornal.id_semana
            INNER JOIN Trabajador ON Jornal.id_trabajador = Trabajador.id_trabajador
            WHERE M_Semana.id_semana = ?
            GROUP BY Trabajador.id_trabajador, Trabajador.nombre
            ORDER BY Trabajador.nombre;''', [id]);
  }
}
