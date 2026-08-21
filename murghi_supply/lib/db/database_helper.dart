import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/daily_rate.dart';
import '../models/account.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'murghi_supply.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_rates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        rate REAL NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountName TEXT NOT NULL,
        address TEXT,
        supplyVehicle TEXT,
        previousBalance REAL DEFAULT 0,
        supplyDiscount REAL DEFAULT 0
      )
    ''');
  }

  // ---------------- Daily Rate CRUD ----------------

  Future<int> insertDailyRate(DailyRate rate) async {
    final db = await database;
    return await db.insert('daily_rates', rate.toMap()..remove('id'));
  }

  Future<List<DailyRate>> getAllDailyRates() async {
    final db = await database;
    final result = await db.query('daily_rates', orderBy: 'date DESC');
    return result.map((map) => DailyRate.fromMap(map)).toList();
  }

  Future<DailyRate?> getDailyRateByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'daily_rates',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return DailyRate.fromMap(result.first);
  }

  Future<int> updateDailyRate(DailyRate rate) async {
    final db = await database;
    return await db.update(
      'daily_rates',
      rate.toMap(),
      where: 'id = ?',
      whereArgs: [rate.id],
    );
  }

  Future<int> deleteDailyRate(int id) async {
    final db = await database;
    return await db.delete('daily_rates', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Account CRUD ----------------

  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap()..remove('id'));
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await database;
    final result = await db.query('accounts', orderBy: 'accountName ASC');
    return result.map((map) => Account.fromMap(map)).toList();
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}
