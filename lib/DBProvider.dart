import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//import 'model/dog.dart';
import 'model/todo.dart';

const DB_FILE = "todo.db";

class DBProvider {
  // class variable
  static final DBProvider _instance = DBProvider._internal();

  // private named constructor
  DBProvider._internal();

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

  //Future<void> close() async => _db.close();

  // Define a function that inserts todo into the database
  Future<Todo> insertTodo(Todo todo) async {
    // Get a reference to the database.
    final db = await database;

    int newID = await db.insert(
      TABLE_TODO,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return todo.copyWithID(id: newID);
  }

  // A method that retrieves all the Todos from the database.
  Future<List<Todo>> getAllTodos() async {
    // Get a reference to the database.
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(TABLE_TODO);

    Iterable<Todo> todos = results.map((e) => Todo.fromMap(e));
    return Future.value(todos.toList());
  }
}