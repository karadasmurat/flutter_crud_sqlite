import 'package:flutter/widgets.dart';
import 'package:flutter_crud_sqlite/model/factory.dart';
import 'package:flutter_crud_sqlite/services/todo_db_service.dart';
import 'services/DBProvider.dart';
import 'model/todo.dart';

void main() async {
  // Unhandled Exception: Binding has not yet been initialized
  WidgetsFlutterBinding.ensureInitialized();

  //var dbProvider = DBProvider.instance;
  final dbService = TodoDBService();

  // Create a Todo and insert into Todo
  var todo = Todo(title: DateTime.now().toIso8601String(), done: false);
  print(todo);

  todo = await dbService.insertTodo(todo);
  print(todo);

  //update status
  var updatedTodo = Todo(id: todo.id, title: todo.title, done: true);
  int rows = await dbService.updateTodo(updatedTodo);
  print("Rows affected: $rows");

  var searchedTodo = await dbService.getTodoById(todo.id!);
  print("Checking if status is updated: $searchedTodo");

  // We can change concrete factory implementation at runtime
  ModelFactory factory = ModelFromFileFactory();
  var sampleTodos = await factory.createTodos();

  for (var t in sampleTodos) {
    //print(t);
    await dbService.insertTodo(t);
  }

  var todos = await dbService.getAllTodos();
  //for (var todo in todos) print(todo);
}
