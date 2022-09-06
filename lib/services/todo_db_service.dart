import 'package:flutter_crud_sqlite/model/todo.dart';
import 'package:flutter_crud_sqlite/services/DBProvider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as dev;

class TodoDBService {
  final dbProvider = DBProvider.instance;

  // Define a function that inserts todo into the database
  Future<Todo> insertTodo(Todo todo) async {
    // Get a reference to the database.
    final db = await dbProvider.database;

    int newID = await db.insert(
      TABLE_TODO,
      todo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final newTodo = todo.copyWith(id: newID);
    dev.log("Todo saved: $newTodo");

    return newTodo;
  }

  Future<Todo?> getTodoById(int id) async {
    // Get a reference to the database.
    final db = await dbProvider.database;
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
    final db = await dbProvider.database;

    final results = await db.query(
      TABLE_TODO,
      where: "$COLUMN_TODO_TITLE LIKE ?",
      whereArgs: ["%$title%"],
    );
    //results could be an empty list
    //print(results);

    Iterable<Todo> todos = results.map((e) => Todo.fromJson(e));
    //so, couldmk return an empty list
    return todos.toList();
  }

  // A method that retrieves all the Todos from the database.
  Future<List<Todo>> getAllTodos() async {
    // Get a reference to the database.
    final db = await dbProvider.database;

    final List<Map<String, dynamic>> results =
        await db.query(TABLE_TODO, orderBy: "$COLUMN_TODO_DUE DESC");

    Iterable<Todo> todos = results.map((e) => Todo.fromJson(e));
    return todos.toList();
  }

  // Define a function that updates todo
  Future<int> updateTodo(Todo todo) async {
    // Get a reference to the database.
    final db = await dbProvider.database;

    int numberOfChanges = await db.update(
      TABLE_TODO,
      todo.toJson(),
      where: "$COLUMN_TODO_ID = ?",
      whereArgs: [todo.id],
    );

    dev.log("$numberOfChanges row(s) affected.");
    return numberOfChanges;
  }

  // Define a function that deletes todo
  Future<int> deleteTodoById(int todoID) async {
    // Get a reference to the database.
    final db = await dbProvider.database;

    int numberOfChanges = await db.delete(
      TABLE_TODO,
      where: "$COLUMN_TODO_ID = ?",
      whereArgs: [todoID],
    );

    dev.log("Deleted $numberOfChanges rows.");

    return numberOfChanges;
  }
}
