import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud_sqlite/services/DBProvider.dart';
import 'package:flutter_crud_sqlite/model/todo.dart';
import 'package:flutter_crud_sqlite/services/todo_db_service.dart';
import 'package:flutter_crud_sqlite/views/search_todo.dart';
import 'package:flutter_crud_sqlite/widgets/list_item.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final dbProvider = DBProvider.instance;
  final dbService = TodoDBService();
  late Future<List<Todo>> todos;

  // Using a GlobalKey is the recommended way to access a form.
  //Create a global key that uniquely identifies the Form widget and allows validation.
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _due;

  Set<int> _selectedTodoIDs = {};

  @override
  void initState() {
    super.initState();
    todos = dbService.getAllTodos();

    _name = TextEditingController();
    _due = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        title: const Text("My Todos"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              //showSearch(context: context, delegate: MySearchDelegate());
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchTodo(),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              log("Deleting: $_selectedTodoIDs");
              for (var id in _selectedTodoIDs) {
                dbService.deleteTodoById(id);
              }
              setState(() {
                todos = dbService.getAllTodos();
              });
            },
            icon: Badge(
                showBadge: _selectedTodoIDs.isNotEmpty,
                badgeContent: Text("${_selectedTodoIDs.length}"),
                child: const Icon(Icons.delete)),
          ),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  // this is NOT a BoxShape, its ShapeBorder
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.0),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return getBottomSheet(context);
                  },
                );
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<Todo>>(
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
                return ListView.separated(
                  separatorBuilder: (context, index) => const Divider(height: 5.0),

                  //key: UniqueKey(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final todo = data[index];
                    return ListItem(
                      key: ObjectKey(todo),
                      todo: todo,
                      onTileSelected: (todoID, isAdded) {
                        setState(() {
                          if (isAdded) {
                            _selectedTodoIDs.add(todoID);
                          } else {
                            _selectedTodoIDs.remove(todoID);
                          }
                        });

                        log("selected: $_selectedTodoIDs");
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Container getBottomSheet(BuildContext context) {
    return Container(
      //height: 400,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        // the same as showmodal's shape, or there will be a white line difference.
        // use of a transparent canvas could be an option
        borderRadius: BorderRadius.circular(30),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          // If your BottomSheetModel is Column make sure you add mainAxisSize: MainAxisSize.min,
          // otherwise the sheet will cover the whole screen.
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Todo",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: TextFormField(
                controller: _name,
                validator: (value) {
                  return (value == null || value.isEmpty) ? 'Please enter title' : null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue[50],
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                //keyboardType: TextInputType.text,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextFormField(
              controller: _due,
              decoration: InputDecoration(
                labelText: "Due Date",
                prefixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                // icon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                // stop keyboard from appearing
                FocusScope.of(context).requestFocus(FocusNode());

                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );

                if (picked != null) {
                  setState(
                    () => {
                      //data.registrationdate = picked.toString(),
                      _due.text = DateFormat.yMMMMd('en_US').format(picked)
                    },
                  );
                }
              },
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () {
                    _name.clear();
                    _due.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                OutlinedButton(
                  onPressed: () async {
                    // The FormState class contains the validate() method.
                    if (_formKey.currentState!.validate()) {
                      await dbService.insertTodo(
                        Todo(
                          title: _name.text,
                          due: (_due.text.isEmpty)
                              ? null
                              : DateFormat.yMMMMd('en_US').parse(_due.text),
                        ),
                      );
                      _name.clear();
                      _due.clear();
                      setState(() {
                        todos = dbService.getAllTodos();
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("OK"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  final dbProvider = DBProvider.instance;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = "";
          }
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text(query));
    //final todos = await dbProvider.getTodosByTitle("MK");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
