import 'package:cafetero/DataBase/data_base_helper.dart';
import 'package:cafetero/Models/trabaja_model.dart';

class TrabajaDao {
  final database = DatabaseHelper.instance.db;

  Future<List<TrabajaModel>> readAll() async {
    final data = await database.rawQuery('''
    SELECT Trabaja.*,Trabajador.nombre FROM Trabaja
    INNER JOIN Trabajador ON Trabaja.id_trabajador = Trabajador.id_trabajador
    ORDER BY Trabaja.fecha DESC
  ''');
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

  Future<List<TrabajaModel>> trabajosActuales() async {
    final data = await database.rawQuery('''
    SELECT Trabaja.*,Trabajador.nombre FROM Trabaja
    INNER JOIN Trabajador ON Trabaja.id_trabajador = Trabajador.id_trabajador
    INNER JOIN Recogida ON Trabaja.id_recogida = Recogida.id_recogida
    WHERE Recogida.fecha_fin IS NULL
    ORDER BY Trabaja.fecha DESC
  ''');
    return data.map((e) => TrabajaModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> kilosRecogida(String id) async {
    final data = await database.rawQuery('''
    SELECT id_recogida, SUM(kilos_trabajador) AS kilos_totales, SUM(pago) AS pagos
    FROM Trabaja
    GROUP BY id_recogida
    HAVING id_recogida = ?
  ''', [id]);
    return data;
  }

  // Nueva función
  Future<Map<String, dynamic>> getDatosPorRecogida(int? idRecogida) async {
    final data = await database.rawQuery('''
    SELECT Trabajador.nombre, Trabaja.kilos_trabajador, Trabaja.pago
    FROM Trabaja
    INNER JOIN Trabajador ON Trabaja.id_trabajador = Trabajador.id_trabajador
    INNER JOIN Recogida ON Trabaja.id_recogida = Recogida.id_recogida
    WHERE Trabaja.id_recogida = ?
    ''', [idRecogida]);

    if (data.isNotEmpty) {
      // Convierte la lista de mapas en un solo mapa
      final Map<String, dynamic> result = {};
      for (var row in data) {
        final nombre = row['nombre'];
        if (!result.containsKey(nombre)) {
          result[nombre.toString()] = {
            'kilos_trabajador': row['kilos_trabajador'],
            'pago': row['pago'],
          };
        } else {
          result[nombre]['kilos_trabajador'] += row['kilos_trabajador'];
          result[nombre]['pago'] += row['pago'];
        }
      }
      return result;
    } else {
      throw Exception('No data found for id_recogida: $idRecogida');
    }
  }
}
