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

  Future<void> close() async => await _database?.close();

  // Define a function that inserts todo into the database
  Future<Todo> insertTodo(Todo todo) async {
    // Get a reference to the database.
    final db = await database;

    int newID = await db.insert(
      TABLE_TODO,
      todo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final newTodo = todo.copyWith(id: newID);
    print("Todo saved: $newTodo");

    return newTodo;
  }

  Future<Todo?> getTodoById(int id) async {
    // Get a reference to the database.
    final db = await database;
    final results = await db.query(
      TABLE_TODO,
      where: '$COLUMN_TODO_ID = ?',
      whereArgs: [id],
    );

    return results.isNotEmpty ? Todo.fromJson(results.first) : null;

    // returning based on condition v1 - Use the ternary operator
    // "return this or that, based on a condition"
    // return (condition) ? something : somethingElse ;
    //
    // returning based on condition v2
    // if (condition) {
    //  return something ;
    // } else {
    //  return somethingElse
    // }
  }

  Future<List<Todo>> getTodosByTitle(String title) async {
    // Get a reference to the database.
    final db = await database;

    final results = await db.query(
      TABLE_TODO,
      where: "$COLUMN_TODO_TITLE LIKE ?",
      whereArgs: ["%$title%"],
    );

    Iterable<Todo> todos = results.map((e) => Todo.fromJson(e));
    return todos.toList();
  }

  // A method that retrieves all the Todos from the database.
  Future<List<Todo>> getAllTodos() async {
    // Get a reference to the database.
    final db = await database;

    final List<Map<String, dynamic>> results =
        await db.query(TABLE_TODO, orderBy: "$COLUMN_TODO_DUE DESC");

    Iterable<Todo> todos = results.map((e) => Todo.fromJson(e));
    return todos.toList();
  }

  // Define a function that updates todo
  Future<int> updateTodo(Todo todo) async {
    // Get a reference to the database.
    final db = await database;

    int numberOfChanges = await db.update(
      TABLE_TODO,
      todo.toJson(),
      where: "$COLUMN_TODO_ID = ?",
      whereArgs: [todo.id],
    );

    return numberOfChanges;
  }

  // Define a function that deletes todo
  Future<int> deleteTodo(Todo todo) async {
    // Get a reference to the database.
    final db = await database;

    int numberOfChanges = await db.delete(
      TABLE_TODO,
      where: "$COLUMN_TODO_ID = ?",
      whereArgs: [todo.id],
    );

    print("Deleted $numberOfChanges rows.");

    return numberOfChanges;
  }
}
