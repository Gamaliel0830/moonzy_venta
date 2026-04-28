import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'moonzy.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _crearTablas(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _crearTablas(db);
      },
    );
  }

  static Future<void> _crearTablas(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        correo TEXT UNIQUE,
        contrasena TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        telefono TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto TEXT,
        monto REAL,
        tipo TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT,
        monto REAL,
        categoria TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tandas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        monto REAL,
        participantes INTEGER
      )
    ''');
  }

  // ── USUARIOS ──────────────────────────────────────
  static Future<bool> registrarUsuario(String nombre, String correo, String contrasena) async {
    try {
      final db = await database;
      await db.insert('usuarios', {
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
      });
      return true;
    } catch (e) {
      return false; // correo ya existe
    }
  }

  static Future<Map<String, dynamic>?> loginUsuario(String correo, String contrasena) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'correo = ? AND contrasena = ?',
      whereArgs: [correo, contrasena],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ── CLIENTES ──────────────────────────────────────
  static Future<void> insertCliente(Map<String, dynamic> cliente) async {
    final db = await database;
    await db.insert('clientes', cliente);
  }

  static Future<List<Map<String, dynamic>>> getClientes() async {
    final db = await database;
    return await db.query('clientes');
  }

  static Future<void> deleteCliente(int id) async {
    final db = await database;
    await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateCliente(int id, Map<String, dynamic> cliente) async {
  final db = await database;
  await db.update('clientes', cliente, where: 'id = ?', whereArgs: [id]);
}

  // ── VENTAS ────────────────────────────────────────
  static Future<void> insertVenta(Map<String, dynamic> venta) async {
    final db = await database;
    await db.insert('ventas', venta);
  }

  static Future<List<Map<String, dynamic>>> getVentas() async {
    final db = await database;
    return await db.query('ventas');
  }

  static Future<void> deleteVenta(int id) async {
    final db = await database;
    await db.delete('ventas', where: 'id = ?', whereArgs: [id]);
  }

static Future<void> updateVenta(int id, Map<String, dynamic> venta) async {
  final db = await database;
  await db.update('ventas', venta, where: 'id = ?', whereArgs: [id]);
}

  // ── GASTOS ────────────────────────────────────────
  static Future<void> insertGasto(Map<String, dynamic> gasto) async {
    final db = await database;
    await db.insert('gastos', gasto);
  }

  static Future<List<Map<String, dynamic>>> getGastos() async {
    final db = await database;
    return await db.query('gastos');
  }

  static Future<void> deleteGasto(int id) async {
    final db = await database;
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateGasto(int id, Map<String, dynamic> gasto) async {
  final db = await database;
  await db.update('gastos', gasto, where: 'id = ?', whereArgs: [id]);
}

  // ── TANDAS ────────────────────────────────────────
  static Future<void> insertTanda(Map<String, dynamic> tanda) async {
    final db = await database;
    await db.insert('tandas', tanda);
  }

  static Future<List<Map<String, dynamic>>> getTandas() async {
    final db = await database;
    return await db.query('tandas');
  }

  static Future<void> deleteTanda(int id) async {
    final db = await database;
    await db.delete('tandas', where: 'id = ?', whereArgs: [id]);
  }

static Future<void> updateTanda(int id, Map<String, dynamic> tanda) async {
  final db = await database;
  await db.update('tandas', tanda, where: 'id = ?', whereArgs: [id]);
}


  // ── TOTALES PARA DASHBOARD ────────────────────────
  static Future<double> getTotalVentas() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(monto) as total FROM ventas');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<double> getTotalGastos() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(monto) as total FROM gastos');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<double> getTotalDeudas() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT SUM(monto) as total FROM ventas WHERE tipo = 'Crédito'");
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}