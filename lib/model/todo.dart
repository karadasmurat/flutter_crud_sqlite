const TABLE_TODO = "Todo";

const String COLUMN_TODO_ID = 'TodoID';
const String COLUMN_TODO_TITLE = 'Title';
const String COLUMN_TODO_DONE = 'Done';

const String SQL_CREATE_TABLE_TODO = '''CREATE TABLE Todo(
  $COLUMN_TODO_ID INTEGER NOT NULL, 
  $COLUMN_TODO_TITLE TEXT, 
  $COLUMN_TODO_DONE INTEGER,
  PRIMARY KEY($COLUMN_TODO_ID AUTOINCREMENT))''';

const SAMPLE_TODOS = [
  {"Title": "Todo 01", "Done": 0},
  {"Title": "Todo 02", "Done": 0},
  {"Title": "Todo 03", "Done": 0},
  {"Title": "Todo 04", "Done": 0},
  {"Title": "Todo 05", "Done": 0},
];

// A library member is a top-level field, getter, setter, or function.
// so you don’t need a class just to define something. (static methods)
List<Todo> fromListOfMaps(List<Map<String, dynamic>> todoList) {
  Iterable<Todo> todos = todoList.map((e) => Todo.fromMap(e));
  return todos.toList();
}

List<Todo> getSampleTodos() => fromListOfMaps(SAMPLE_TODOS);

class Todo {
  final int? id; // PRIMARY KEY (TodoID AUTOINCREMENT)
  final String title;
  final bool done; // bool will map to INTEGER in SQLite.

  Todo({
    this.id, // id is optional
    required this.title,
    required this.done,
  });

  // create a new Todo with the given id, by copying fields of this.
  Todo copyWithID({required int id}) =>
      Todo(id: id, title: this.title, done: this.done);

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
        id: map[COLUMN_TODO_ID],
        title: map[COLUMN_TODO_TITLE],
        done: map[COLUMN_TODO_DONE] == 0 ? false : true);
  }

  Map<String, Object?> toMap() => {
        COLUMN_TODO_ID: id,
        COLUMN_TODO_TITLE: title,
        COLUMN_TODO_DONE: done == true ? 1 : 0,
      };

  /// The equality operator.
  /// The default behavior for all [Object]s is to return true if and
  /// only if this object and [other] are the same object.
  /// If a subclass overrides the equality operator, it should override
  /// the [hashCode] method as well to maintain consistency.
  @override
  bool operator ==(covariant Todo other) => id == other.id;

  /// The hash code for this object.
  /// A hash code is a single integer which represents the state of the object
  /// that affects [operator ==] comparisons. Hash codes must be the same
  /// for objects that are equal to each other according to [operator ==].
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "{id:$id title:$title done:$done }";
  }
}
