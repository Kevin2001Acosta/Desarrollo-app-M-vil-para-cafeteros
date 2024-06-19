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

  Future<List<Map<String, dynamic>>> getVentasbyMes(String anio) async {
    return await database.rawQuery('''
    SELECT 
      strftime('%m', fecha) as mes, 
      SUM(kilos_vendidos) / 12.5 as arrobas_vendidas, 
      SUM(venta_total) as venta_total
    FROM 
      Ventas_Cafe
    WHERE 
      strftime('%Y', fecha) = ?
    GROUP BY 
      mes
    ORDER BY 
      mes;
    ''', [anio]);
  }
}
