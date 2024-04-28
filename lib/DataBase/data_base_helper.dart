import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;

  DatabaseHelper._internal();
  static DatabaseHelper get instance =>
      _databaseHelper ??= DatabaseHelper._internal();

  Database? _db;

  Database get db => _db!;

  Future<void> init() async {
    _db = await openDatabase('cafeteros.db', version: 1,
        onCreate: (db, version) async {
      await db.execute('''
    CREATE TABLE Trabajador (
    id_trabajador INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT UNIQUE NOT NULL);
    ''');
      await db.execute('''
    CREATE TABLE Cosecha (
    id_cosecha INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    kilos_totales INTEGER);
    ''');
      await db.execute('''
    CREATE TABLE Recogida (
    id_recogida INTEGER PRIMARY KEY AUTOINCREMENT,
    jornal INTEGER CHECK(jornal IN (0, 1)),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    kilos_totales INTEGER,
    precio_kilo INTEGER,
    id_cosecha INTEGER NOT NULL,
    FOREIGN KEY (id_cosecha) REFERENCES Cosecha(id_cosecha)
    );

    ''');
      await db.execute('''
    CREATE TABLE Trabaja (
    id_trabaja INTEGER PRIMARY KEY AUTOINCREMENT,
    id_trabajador INTEGER,
    id_recogida INTEGER,
    pago INTEGER,
    kilos_trabajador INTEGER,
    fecha DATE,
    FOREIGN KEY (id_trabajador) REFERENCES Trabajador(id_trabajador),
    FOREIGN KEY (id_recogida) REFERENCES Recogida(id_recogida)
    );

    ''');
    });
  }
}
