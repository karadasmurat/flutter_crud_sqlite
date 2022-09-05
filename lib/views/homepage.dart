import 'package:flutter/material.dart';
import 'package:flutter_crud_sqlite/DBProvider.dart';
import 'package:flutter_crud_sqlite/model/todo.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbProvider = DBProvider.instance;
  late Future<List<Todo>> todos;

  late TextEditingController _name;
  late TextEditingController _due;

  @override
  void initState() {
    super.initState();
    todos = dbProvider.getAllTodos();

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
                showModalBottomSheet(
                  context: context,
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
                return ListView.builder(
                  key: UniqueKey(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final todo = snapshot.data![index];
                    return Card(
                      color: (todo.due != null && DateTime.now().compareTo(todo.due!) > 0)
                          ? Colors.amberAccent
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Todo",
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _name,
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
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              OutlinedButton(
                onPressed: () async {
                  await dbProvider.insertTodo(
                    Todo(
                      title: _name.text,
                      due: DateFormat.yMMMMd('en_US').parse(_due.text),
                    ),
                  );
                  setState(() {
                    todos = dbProvider.getAllTodos();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
