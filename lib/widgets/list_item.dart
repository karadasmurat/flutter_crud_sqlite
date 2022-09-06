import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_crud_sqlite/model/todo.dart';
import 'package:flutter_crud_sqlite/services/todo_db_service.dart';
import 'package:intl/intl.dart';

// Step 1: Define a Callback.
typedef void IntCallback(int todoID, bool toBeAdded);

class ListItem extends StatefulWidget {
  final Todo todo;
  final IntCallback onTileSelected;

  const ListItem({
    Key? key,
    required this.todo,
    required this.onTileSelected,
  }) : super(key: key);

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final dbService = TodoDBService();

  bool _editMode = false;
  double _height = 2.0;
  Color? _color = Colors.transparent;
  bool _selected = false;

  late TextEditingController _name;
  late TextEditingController _due;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.todo.title);
    _due = TextEditingController();
    if (widget.todo.due != null) {
      _due.text = DateFormat.yMMMMd('en_US').format(widget.todo.due!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //contentPadding: EdgeInsets.zero,
      //dense: true,

      tileColor:
          (widget.todo.due != null && DateTime.now().compareTo(widget.todo.due!) > 0)
              ? Colors.amberAccent //Theme.of(context).colorScheme.secondary
              : Colors.white,
      //enabled: false,
      //visualDensity: VisualDensity(vertical: 4), // to expand
      selected: _selected,
      selectedTileColor: Colors.green[200],
      title: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        // padding: const EdgeInsets.only(left: 14),
        // height: 40,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(5),
          //border: Border.all(),
        ),
        child: TextFormField(
          enabled: _editMode,
          controller: _name,
          //maxLines: 1,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            //filled: true,
            //fillColor: Colors.blue[200],
            hintText: 'Enter a title',
            border: InputBorder.none,

            // height of the textfield
            isDense: true,
            contentPadding: EdgeInsets.all(_height),
          ),
        ),
      ),

      //subtitle
      subtitle: TextFormField(
        enabled: _editMode,
        controller: _due,
        // The subtitle's default TextStyle depends on TextTheme.bodyText2 except TextStyle.color.
        // The TextStyle.color depends on the value of enabled and selected.
        style: Theme.of(context)
            .textTheme
            .bodyText2
            ?.copyWith(color: Theme.of(context).disabledColor),

        decoration: const InputDecoration(
          border: InputBorder.none,
          // height of the textfield
          isDense: true,
          contentPadding: EdgeInsets.all(2.0),
        ),
      ),

      // The icon button which will notify list item to change
      trailing: OutlinedButton(
        style: OutlinedButton.styleFrom(
          //OutlinedBorder? shape
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(4),
          //elevation: 2,
        ),
        child: _editMode ? const Icon(Icons.save) : const Icon(Icons.edit),
        onPressed: () {
          setState(
            () {
              _editMode = !_editMode;
              // _height = editable ? 80 : 40;
              if (_editMode) {
                _height = 10;
                _color = Colors.grey[300];
              } else {
                _height = 2;
                _color = Colors.transparent;

                // log("Call update service.");
                // TODO check if the field is dirty before db.update
                dbService.updateTodo(widget.todo.copyWith(title: _name.text));
              }
            },
          );
        },
      ),

      // when onTap, toggle selection of the ListTile
      onTap: () {
        setState(() {
          _selected = !_selected;
        });

        widget.onTileSelected(widget.todo.id ?? -1, _selected);
      },
    );
  }
}
