import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'todo.dart';

abstract class ModelFactory {
  Future createTodos();
  //Future<List<Car>> createCars();
}

class ModelFromFileFactory implements ModelFactory {
  @override
  Future createTodos() async {
    // read an asset, .json file
    var decodedJson = await loadTodosFromFile("assets/json/todos.json");

    if (decodedJson is List) {
      Iterable<Todo> todos = decodedJson.map((e) => Todo.fromJson(e));
      return Future.value(todos.toList());
    } else {
      List<Todo> todos = [];
      todos.add(Todo.fromJson(decodedJson));
      return todos;
    }
  }
}

class ModelFromHttpFactory implements ModelFactory {
  @override
  Future<List<Todo>> createTodos() async {
    // TODO
    // make an API call, and decode response.body
    var response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

    var todos = <Todo>[];
    return Future.value(todos);
  }
}

dynamic loadTodosFromFile(String aFile) async {
  String todosFromJsonFile = await rootBundle.loadString(aFile);
  return jsonDecode(todosFromJsonFile);
}
