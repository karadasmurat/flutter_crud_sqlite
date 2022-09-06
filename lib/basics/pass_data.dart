import 'package:flutter/material.dart';

// Step 1: Define a Callback.
typedef void IntCallback(int id);

class Son extends StatelessWidget {
  // Step 2: Configre the child to expect a callback in the constructor(next 2 lines):
  final IntCallback onSonChanged;

  Son({required this.onSonChanged});

  int childData = 3;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Özetle, verdigimiz callback fonksiyonunu "uygun zamanda" parametreleri doldurarak cagiriyor:
        onSonChanged(childData);
      },
      child: const Text('Click me to call the callback!'),
    );
  }
}

class Father extends StatefulWidget {
  @override
  State<Father> createState() => _FatherState();
}

class _FatherState extends State<Father> {
  // Step 1 (optional): Define a Global variable
  // to store the data comming back from the child.
  int parentData = 0;

  // Step 2: Define a function with the same signature
  // as the callback, so the callback will point to it,
  // this new function will get the data from the child,
  // set it to the global variable (from step 1)
  // in the parent, and then update the UI by setState((){});
  void updateData(int data) {
    setState(() {
      parentData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Step 3: Construct a child widget and pass the
      child: Son(
        // 1st option:
        onSonChanged: (newId) {
          updateData(newId);
        },
        // 2nd option: onSonChanged: updateId,
        // 3rd option: onSonChanged: (int newId) => updateId(newId)

        // So each time the 'onSonChanged' called by the action
        // we defined inside the child, a new data will be
        // passed to this parent.
      ),
    );
  }
}
