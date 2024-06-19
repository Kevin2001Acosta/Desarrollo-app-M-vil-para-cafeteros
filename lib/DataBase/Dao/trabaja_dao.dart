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

  // Nueva función modificada
  Future<List<Map<String, dynamic>>> getDatosPorRecogida(int? idRecogida) async {
    final data = await database.rawQuery('''
    SELECT Trabaja.fecha, Trabajador.nombre, Trabaja.kilos_trabajador, Trabaja.pago
    FROM Trabaja
    INNER JOIN Trabajador ON Trabaja.id_trabajador = Trabajador.id_trabajador
    WHERE Trabaja.id_recogida = ?
    ORDER BY Trabaja.fecha DESC
    ''', [idRecogida]);

    if (data.isNotEmpty) {
      // Devuelve la lista de mapas directamente
      return data.map((row) {
        return {
          'fecha': row['fecha'],
          'nombre': row['nombre'] ?? 'Desconocido',
          'kilos_trabajador': row['kilos_trabajador'] ?? 0.0,
          'pago': row['pago'] ?? 0.0,
        };
      }).toList();
    } else {
      throw Exception('No data found for id_recogida: $idRecogida');
    }
  }
}
