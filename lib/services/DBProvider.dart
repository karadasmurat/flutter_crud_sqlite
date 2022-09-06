import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//import 'model/dog.dart';
import '../model/todo.dart';

const DB_FILE = "todo.db";

class DBProvider {
  // private static instance, initialized by the private constructor
  static final DBProvider _instance = DBProvider._internal();

  // private named constructor
  DBProvider._internal();

  // the global access point to the single instance
  // static getter
  static DBProvider get instance => _instance;

  Database? _database;

  Future<Database> get database async {
    return _database ?? await initDb();

    // if (_db == null) {
    //   _db = await initDb();
    // }
    // return _db;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), DB_FILE);
    Database dbase = await openDatabase(
      path,
      version: 1,
      // [onCreate] is called if the database did not exist prior to calling [openDatabase].
      onCreate: (Database db, int version) async {
        await db.execute(SQL_CREATE_TABLE_TODO);
      },
    );
    // set instance variable, getter checks for this
    _database = dbase;

    return dbase;
  }

  Future<void> close() async => await _database?.close();
}
