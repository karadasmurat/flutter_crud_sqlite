import 'package:flutter/material.dart';

// test file for now:
// flutter run lib/db_todo_test.dart

void main() {
  runApp(
    MaterialApp(
      //When using initialRoute, don’t define a home property.
      //home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: "Open Sans",
        primarySwatch: Colors.blue,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan[600]),
      ),
      initialRoute: "/home",
      routes: {
        "/home": (context) => HomePage(title: "SQLITE CRUD"),
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(),
    );
  }
}
