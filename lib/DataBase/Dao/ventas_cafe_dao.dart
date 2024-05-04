import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/ventas_cafe_model.dart';


class VentasCafeDao {
  final database = DatabaseHelper.instance.db;

  Future<List<VentasCafeModel>> readAll() async {
    final data = await database.query('Ventas_Cafe');
    return data.map((e) => VentasCafeModel.fromJson(e)).toList();
  }

  Future<int> insert(VentasCafeModel ventas) async {
    return await database.insert('Ventas_Cafe', ventas.toJson());
  }

  Future<void> update(VentasCafeModel ventas) async {
    await database.update('Ventas_Cafe', ventas.toJson(),
        where: 'id_ventas = ?', whereArgs: [ventas.idVentas]);
  }

  Future<void> delete(VentasCafeModel ventas) async {
    await database.delete('Ventas_Cafe',
        where: 'id_ventas = ?', whereArgs: [ventas.idVentas]);
  }
}