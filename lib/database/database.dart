import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String _tableName = 'http_cache_test';
  String colId = 'id';
  String colScreen = 'screen';
  String colResponse = 'response';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'http_cache_test.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
      onOpen: (db) => print('Database is being opened!'),
    );
  }

  void _createDb(Database db, int version) async {
    print('Database is being created');
    await db.execute(
        'CREATE TABLE $_tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colScreen TEXT UNIQUE, $colResponse TEXT)');
  }

  //Returns a list of map;
  Future<List<Map<String, dynamic>>> getAllValues() async {
    Database database = await this.database;
    var result = await database.query(_tableName);
    return result;
  }

  Future<int> insertData(String screenName, String response) async {
    Database database = await this.database;
    var result = await database.insert(_tableName, {
      colScreen: screenName,
      colResponse: response,
    });
    return result;
  }

  Future<List<Map<String, dynamic>>> getScreenResponse(String keyword) async {
    Database database = await this.database;
    var result = await database
        .rawQuery('SELECT * FROM $_tableName WHERE $colScreen = "$keyword"');
    return result;
  }

  Future<int> updateData(String screenName, String response) async {
    Database database = await this.database;
    var result = await database.update(
      _tableName,
      {colScreen: screenName, colResponse: response},
      where: '$colScreen = ?',
      whereArgs: [screenName],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  Future<int> deleteData(String screenName) async {
    Database database = await this.database;
    var result = await database.delete(
      _tableName,
      where: '$_tableName = ?',
      whereArgs: [screenName],
    );
    return result;
  }

  Future<int> getCount() async {
    Database database = await this.database;
    var result = await database.rawQuery('SELECT COUNT (*) FROM $_tableName');
    return Sqflite.firstIntValue(result);
  }

  Future<void> dropTable() async {
    print('Table is being deleted');
    Database database = await this.database;
    database.rawQuery('DROP TABLE $_tableName');
  }
}
