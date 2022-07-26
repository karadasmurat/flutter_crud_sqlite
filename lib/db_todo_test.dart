import 'package:flutter/widgets.dart';
import 'DBProvider.dart';
import 'model/todo.dart';

void main() async {
  // Unhandled Exception: Binding has not yet been initialized
  WidgetsFlutterBinding.ensureInitialized();

  var dbProvider = DBProvider.instance;

  // Create a Todo and insert into Todo
  var todo = Todo(title: DateTime.now().toIso8601String(), done: false);
  print(todo);

  todo = await dbProvider.insertTodo(todo);
  print(todo);

  List<Todo> sampleTodos = getSampleTodos();
  for (var t in sampleTodos) {
    print(t);
    await dbProvider.insertTodo(t);
  }

  var todos = await dbProvider.getAllTodos();
  print(todos);
}
