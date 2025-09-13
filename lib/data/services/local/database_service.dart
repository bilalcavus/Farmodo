// import 'package:sqflite/sqflite.dart';
// import 'package:sqflite/sqlite_api.dart';
// import 'package:path/path.dart';


// class DatabaseService {
//   static final DatabaseService _instance = DatabaseService._internal();
//   factory DatabaseService() => _instance;
//   DatabaseService._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'farmodo.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//       onUpgrade: _onUpgrade,
//     );
//   }

//   Future<Database> _onCreate(Database db, int version) async {
//     await db.execute(''' 
//       CREATE TABLE local_gained (
//         id TEXT PRIMARY KEY,
//         totalXp INTEGER,
//         level INTEGER,
//       )
//      ''');

//      await db.execute('''
//       CREATE TABLE local_tasks(
//         id TEXT PRIMARY KEY,
//         xpReward INTEGER NOT NULL,
//         title TEXT NOT NULL,
//         totalS
//       )
//     ''')
//   }
// }