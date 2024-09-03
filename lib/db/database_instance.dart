import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:pengelolaan_keuangan_masjid/db/pemasukan_model.dart';
import 'package:pengelolaan_keuangan_masjid/db/pengeluaran_model.dart';
import 'package:pengelolaan_keuangan_masjid/db/tabungan_model.dart';
import 'package:pengelolaan_keuangan_masjid/db/users_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseInstance {
  static final DatabaseInstance _instance = DatabaseInstance._init();
  static Database? _database;

  DatabaseInstance._init();

  factory DatabaseInstance() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nama TEXT NOT NULL,
        no_hp TEXT NOT NULL,
        alamat TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pemasukan (
        idpemasukan INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        jenispemasukan TEXT NOT NULL,
        deskripsipemasukan TEXT NOT NULL,
        jumlahpemasukan REAL NOT NULL,
        tanggalpemasukan TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pengeluaran (
        idpengeluaran INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        jenispengeluaran TEXT NOT NULL,
        deskripsipengeluaran TEXT NOT NULL,
        jumlahpengeluaran REAL NOT NULL,
        tanggalpengeluaran TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tabungan (
        idtabungan INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        namajamaah TEXT NOT NULL,
        jumlahtabungan REAL NOT NULL,
        tanggaltabungan TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<int> insertUser(User user) async {
    final db = await database;

    final result = await db.query('users', where: 'username = ?', whereArgs: [user.username]);
    if (result.isNotEmpty) {
      throw Exception('Username already exists');
    }

    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertPemasukan(Pemasukan pemasukan) async {
    final db = await database;
    return await db.insert('pemasukan', pemasukan.toMap());
  }

  Future<List<Pemasukan>> getPemasukan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pemasukan');

    return maps.map((map) => Pemasukan.fromMap(map)).toList();
  }

  Future<int> updatePemasukan(Pemasukan pemasukan) async {
    final db = await database;
    return await db.update(
      'pemasukan',
      pemasukan.toMap(),
      where: 'idpemasukan = ?',
      whereArgs: [pemasukan.idpemasukan],
    );
  }

  Future<int> deletePemasukan(int id) async {
    final db = await database;
    return await db.delete(
      'pemasukan',
      where: 'idpemasukan = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertPengeluaran(Pengeluaran pengeluaran) async {
    final db = await database;
    return await db.insert('pengeluaran', pengeluaran.toMap());
  }

  Future<List<Pengeluaran>> getPengeluaran() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pengeluaran');

    return maps.map((map) => Pengeluaran.fromMap(map)).toList();
  }

  Future<int> updatePengeluaran(Pengeluaran pengeluaran) async {
    final db = await database;
    return await db.update(
      'pengeluaran',
      pengeluaran.toMap(),
      where: 'idpengeluaran = ?',
      whereArgs: [pengeluaran.idpengeluaran],
    );
  }

  Future<int> deletePengeluaran(int id) async {
    final db = await database;
    return await db.delete(
      'pengeluaran',
      where: 'idpengeluaran = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertTabungan(Tabungan tabungan) async {
    final db = await database;
    return await db.insert('tabungan', tabungan.toMap());
  }

  Future<List<Tabungan>> getTabungan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tabungan');

    return maps.map((map) => Tabungan.fromMap(map)).toList();
  }

  Future<int> updateTabungan(Tabungan tabungan) async {
    final db = await database;
    return await db.update(
      'tabungan',
      tabungan.toMap(),
      where: 'idtabungan = ?',
      whereArgs: [tabungan.id],
    );
  }

  Future<int> deleteTabungan(int id) async {
    final db = await database;
    return await db.delete(
      'tabungan',
      where: 'idtabungan = ?',
      whereArgs: [id],
    );
  }

  Future<List<Pemasukan>> getAllPemasukan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pemasukan');

    return maps.map((map) => Pemasukan.fromMap(map)).toList();
  }

  Future<List<Pengeluaran>> getAllPengeluaran() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pengeluaran');

    return maps.map((map) => Pengeluaran.fromMap(map)).toList();
  }
}