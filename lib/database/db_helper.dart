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
      version: 5,
      onCreate: (db, version) async {
        await _crearTablas(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS clientes');
        await db.execute('DROP TABLE IF EXISTS ventas');
        await db.execute('DROP TABLE IF EXISTS gastos');
        await db.execute('DROP TABLE IF EXISTS tandas');
        await db.execute('DROP TABLE IF EXISTS tanda_participantes');
        await db.execute('DROP TABLE IF EXISTS tanda_semanas');
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
        id_usuario INTEGER,
        nombre TEXT,
        telefono TEXT,
        debe INTEGER DEFAULT 0,
        monto_deuda REAL DEFAULT 0.0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER,
        producto TEXT,
        monto REAL,
        tipo TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER,
        descripcion TEXT,
        monto REAL,
        categoria TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tandas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER,
        nombre TEXT,
        monto REAL,
        participantes INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tanda_participantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_tanda INTEGER,
        nombre TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tanda_semanas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_tanda INTEGER,
        id_participante INTEGER,
        semana INTEGER,
        pagado INTEGER DEFAULT 0
      )
    ''');
  }

  // ── USUARIOS ──────────────────────────────────────
  static Future<bool> registrarUsuario(
      String nombre, String correo, String contrasena) async {
    try {
      final db = await database;
      await db.insert('usuarios', {
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> loginUsuario(
      String correo, String contrasena) async {
    final db = await database;
    final result = await db.query('usuarios',
        where: 'correo = ? AND contrasena = ?',
        whereArgs: [correo, contrasena]);
    return result.isNotEmpty ? result.first : null;
  }

  // ── CLIENTES ──────────────────────────────────────
  static Future<void> insertCliente(Map<String, dynamic> cliente) async {
    final db = await database;
    await db.insert('clientes', cliente);
  }

  static Future<List<Map<String, dynamic>>> getClientes(int idUsuario) async {
    final db = await database;
    return await db.query('clientes',
        where: 'id_usuario = ?', whereArgs: [idUsuario]);
  }

  static Future<void> updateCliente(
      int id, Map<String, dynamic> cliente) async {
    final db = await database;
    await db.update('clientes', cliente, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteCliente(int id) async {
    final db = await database;
    await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

  // ── VENTAS ────────────────────────────────────────
  static Future<void> insertVenta(Map<String, dynamic> venta) async {
    final db = await database;
    await db.insert('ventas', venta);
  }

  static Future<List<Map<String, dynamic>>> getVentas(int idUsuario) async {
    final db = await database;
    return await db.query('ventas',
        where: 'id_usuario = ?', whereArgs: [idUsuario]);
  }

  static Future<void> updateVenta(int id, Map<String, dynamic> venta) async {
    final db = await database;
    await db.update('ventas', venta, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteVenta(int id) async {
    final db = await database;
    await db.delete('ventas', where: 'id = ?', whereArgs: [id]);
  }

  // ── GASTOS ────────────────────────────────────────
  static Future<void> insertGasto(Map<String, dynamic> gasto) async {
    final db = await database;
    await db.insert('gastos', gasto);
  }

  static Future<List<Map<String, dynamic>>> getGastos(int idUsuario) async {
    final db = await database;
    return await db.query('gastos',
        where: 'id_usuario = ?', whereArgs: [idUsuario]);
  }

  static Future<void> updateGasto(int id, Map<String, dynamic> gasto) async {
    final db = await database;
    await db.update('gastos', gasto, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteGasto(int id) async {
    final db = await database;
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  // ── TANDAS ────────────────────────────────────────
  static Future<void> insertTanda(Map<String, dynamic> tanda) async {
    final db = await database;
    await db.insert('tandas', tanda);
  }

  static Future<List<Map<String, dynamic>>> getTandas(int idUsuario) async {
    final db = await database;
    return await db.query('tandas',
        where: 'id_usuario = ?', whereArgs: [idUsuario]);
  }

  static Future<void> updateTanda(int id, Map<String, dynamic> tanda) async {
    final db = await database;
    await db.update('tandas', tanda, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteTanda(int id) async {
    final db = await database;
    await db.delete('tandas', where: 'id = ?', whereArgs: [id]);
  }

  // ── PARTICIPANTES ─────────────────────────────────
  static Future<void> insertParticipante(
      Map<String, dynamic> participante) async {
    final db = await database;
    await db.insert('tanda_participantes', participante);
  }

  static Future<List<Map<String, dynamic>>> getParticipantes(
      int idTanda) async {
    final db = await database;
    return await db.query('tanda_participantes',
        where: 'id_tanda = ?', whereArgs: [idTanda]);
  }

  static Future<void> updateParticipante(
      int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('tanda_participantes', data,
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteParticipantesByTanda(int idTanda) async {
    final db = await database;
    await db.delete('tanda_semanas',
        where: 'id_tanda = ?', whereArgs: [idTanda]);
    await db.delete('tanda_participantes',
        where: 'id_tanda = ?', whereArgs: [idTanda]);
  }

  // ── SEMANAS ───────────────────────────────────────
  static Future<void> insertSemana(Map<String, dynamic> semana) async {
    final db = await database;
    await db.insert('tanda_semanas', semana);
  }

  static Future<List<Map<String, dynamic>>> getSemanasByTanda(
      int idTanda, int semana) async {
    final db = await database;
    return await db.query('tanda_semanas',
        where: 'id_tanda = ? AND semana = ?',
        whereArgs: [idTanda, semana]);
  }

  static Future<int> getUltimaSemana(int idTanda) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT MAX(semana) as ultima FROM tanda_semanas WHERE id_tanda = ?',
        [idTanda]);
    return (result.first['ultima'] as int?) ?? 0;
  }

  static Future<void> updateSemana(int id, int pagado) async {
    final db = await database;
    await db.update('tanda_semanas', {'pagado': pagado},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> iniciarNuevaSemana(int idTanda,
      List<Map<String, dynamic>> participantes, int semana) async {
    final db = await database;
    for (final p in participantes) {
      await db.insert('tanda_semanas', {
        'id_tanda': idTanda,
        'id_participante': p['id'],
        'semana': semana,
        'pagado': 0,
      });
    }
  }

 static Future<List<Map<String, dynamic>>> getParticipantesConSemana(
    int idTanda, int semana) async {
  final db = await database;
  final participantes = await db.query('tanda_participantes',
      where: 'id_tanda = ?', whereArgs: [idTanda]);
  
  final List<Map<String, dynamic>> resultado = [];
  for (final p in participantes) {
    final semanaData = await db.query('tanda_semanas',
        where: 'id_participante = ? AND semana = ? AND id_tanda = ?',
        whereArgs: [p['id'], semana, idTanda]);
    
    resultado.add({
      'id': p['id'],
      'nombre': p['nombre'],
      'pagado': semanaData.isNotEmpty ? semanaData.first['pagado'] : 0,
      'semana_id': semanaData.isNotEmpty ? semanaData.first['id'] : null,
    });
  }
  return resultado;
}
  // ── TOTALES DASHBOARD ─────────────────────────────
  static Future<double> getTotalVentas(int idUsuario) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(monto) as total FROM ventas WHERE id_usuario = ?',
        [idUsuario]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<double> getTotalGastos(int idUsuario) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(monto) as total FROM gastos WHERE id_usuario = ?',
        [idUsuario]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  static Future<double> getTotalDeudas(int idUsuario) async {
    final db = await database;
    final resultVentas = await db.rawQuery(
        "SELECT SUM(monto) as total FROM ventas WHERE tipo = 'Crédito' AND id_usuario = ?",
        [idUsuario]);
    final deudaVentas =
        (resultVentas.first['total'] as num?)?.toDouble() ?? 0.0;
    final resultClientes = await db.rawQuery(
        "SELECT SUM(monto_deuda) as total FROM clientes WHERE debe = 1 AND id_usuario = ?",
        [idUsuario]);
    final deudaClientes =
        (resultClientes.first['total'] as num?)?.toDouble() ?? 0.0;
    return deudaVentas + deudaClientes;
  }
}