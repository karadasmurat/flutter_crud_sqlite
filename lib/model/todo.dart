const TABLE_TODO = "Todo";

const String COLUMN_TODO_ID = 'TodoID';
const String COLUMN_TODO_TITLE = 'Title';
const String COLUMN_TODO_DONE = 'Done';
const String COLUMN_TODO_DUE = 'Due';

const String SQL_CREATE_TABLE_TODO = '''CREATE TABLE Todo(
  $COLUMN_TODO_ID INTEGER NOT NULL, 
  $COLUMN_TODO_TITLE TEXT NOT NULL, 
  $COLUMN_TODO_DONE INTEGER,
  $COLUMN_TODO_DUE TEXT,
  PRIMARY KEY($COLUMN_TODO_ID AUTOINCREMENT))''';

class Todo {
  final int? id; // PRIMARY KEY (TodoID AUTOINCREMENT)
  final String title;
  final bool done; // bool will map to INTEGER in SQLite.
  final DateTime? due; // DateTime will map to Text in SQLite (ISO8601)

  Todo({
    this.id, // id is optional
    required this.title,
    this.done = false, //default value for non-nullable but optional field
    this.due,
  });

  /// Creates a copy of this todo with the given fields
  /// replaced by the non-null parameter values.
  Todo copyWith({
    int? id,
    String? title,
    bool? done,
    DateTime? due,
  }) =>
      Todo(
        id: id ?? this.id,
        title: title ?? this.title,
        done: done ?? this.done,
        due: due ?? this.due,
      );

  factory Todo.fromJson(Map<String, dynamic> map) => Todo(
        id: map[COLUMN_TODO_ID],
        title: map[COLUMN_TODO_TITLE],
        done: map[COLUMN_TODO_DONE] == 0 ? false : true,
        due: map[COLUMN_TODO_DUE] == null ? null : DateTime.parse(map[COLUMN_TODO_DUE]),
      );

  Map<String, Object?> toJson() => {
        COLUMN_TODO_ID: id,
        COLUMN_TODO_TITLE: title,
        COLUMN_TODO_DONE: done == true ? 1 : 0,
        COLUMN_TODO_DUE: due?.toIso8601String(),
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
  String toString() =>
      "{hashcode:$hashCode, id:$id, title:$title, done:$done, due: $due}";
}
