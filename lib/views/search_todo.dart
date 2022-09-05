import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_crud_sqlite/DBProvider.dart';
import 'package:flutter_crud_sqlite/model/todo.dart';
import 'package:intl/intl.dart';

class SearchTodo extends StatefulWidget {
  const SearchTodo({Key? key}) : super(key: key);

  @override
  State<SearchTodo> createState() => _SearchTodoState();
}

class _SearchTodoState extends State<SearchTodo> {
  final dbProvider = DBProvider.instance;
  late Future<List<Todo>> todos;
  late TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    todos = Future.value([]);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.only(left: 14),
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextFormField(
              controller: _search,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      todos = dbProvider.getTodosByTitle(_search.text);
                    });
                  },
                ),
                hintText: "Search",
                border: InputBorder.none,
              ),
              onChanged: (q) {
                setState(() {
                  todos = dbProvider.getTodosByTitle(q);
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Todo>>(
        future: todos,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Text("Error");
          } else {
            final data = snapshot.data!;
            return buildTodoList(data);
          }
        },
      ),
    );
  }

  Widget buildTodoList(List<Todo> todoList) {
    return ListView.builder(
      //key: UniqueKey(),
      itemCount: todoList.length,
      itemBuilder: (context, index) {
        final todo = todoList[index];
        return Card(
          color: (todo.due != null && DateTime.now().compareTo(todo.due!) > 0)
              ? Colors.amberAccent //Theme.of(context).colorScheme.secondary
              : null,
          key: ObjectKey(todo),
          child: ListTile(
            title: Text(todo.title),
            subtitle: todo.due != null
                ? Text(DateFormat.yMMMMd('en_US').format(todo.due!))
                : const Text(""),
            trailing: IconButton(
                onPressed: () {
                  dbProvider.deleteTodo(todo);
                  setState(() {
                    todos = dbProvider.getAllTodos();
                  });
                },
                icon: const Icon(Icons.delete)),
          ),
        );
      },
    );
  }
}
