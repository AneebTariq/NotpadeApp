import 'package:flutter/material.dart';
import 'package:notepad/screens/note_detail.dart';
import 'dart:async';
import 'package:notepad/models/note.dart';
import 'package:notepad/utils/database_helper.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';

// ignore: camel_case_types, use_key_in_widget_constructors
class notelist extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return noteliststate();
  }
}

// ignore: camel_case_types
class noteliststate extends State<notelist> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  List<Note>? noteList;
  int? count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = <Note>[];
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: "ADD Note",
        child: const Icon(Icons.add),
      ),
      body: getnotelistview(),
    );
  }

  ListView getnotelistview() {
    TextStyle titleStyle = Theme.of(context).textTheme.headline1!;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 20.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(noteList![position].priority),
              child: getPriorityIcon(noteList![position].priority),
            ),
            title: Text(
              noteList![position].title,
              style: titleStyle,
            ),
            subtitle: Text(
              noteList![position].date,
              style: titleStyle,
            ),
            trailing: GestureDetector(
              child: const Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                _delete(context, noteList![position]);
              },
            ),
            onTap: () {
              navigateToDetail(noteList![position], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      //break;
      case 2:
        return Colors.yellow;
      //break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return const Icon(Icons.play_arrow);
      case 2:
        return const Icon(Icons.keyboard_arrow_right);

      default:
        return const Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      // ignore: use_build_context_synchronously
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    var result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return notedetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          noteList = noteList;
          count = noteList.length;
        });
      });
    });
  }
}
