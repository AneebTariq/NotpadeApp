import 'package:flutter/material.dart';
import 'package:notepad/screens/note_list.dart';

void main() {
  runApp(myapp());
}

// ignore: camel_case_types, use_key_in_widget_constructors
class myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NotePad",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: notelist(),
    );
  }
}
