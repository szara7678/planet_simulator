// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'simulation.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE SimulationState (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resourceCount REAL,
        creaturesState TEXT
      )
    ''');
  }

  Future<int> insertSimulationState(double resourceCount, String creaturesState) async {
    final db = await database;
    final data = {
      'resourceCount': resourceCount,
      'creaturesState': creaturesState,
    };
    return await db.insert('SimulationState', data);
  }

  Future<List<Map<String, dynamic>>> getSimulationStates() async {
    final db = await database;
    return await db.query('SimulationState');
  }
}
