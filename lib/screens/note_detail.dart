import 'package:flutter/material.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/utils/database_helper.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

// ignore: camel_case_types
class notedetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  // ignore: use_key_in_widget_constructors
  const notedetail(
    this.note,
    this.appBarTitle,
  );

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return notedetailstate(note, appBarTitle);
  }
}

// ignore: camel_case_types
class notedetailstate extends State<notedetail> {
  DatabaseHelper helper = DatabaseHelper();
  Note note;

  String appBarTitle;
  static final _priorities = ['High', 'Low'];
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController disccontroller = TextEditingController();
  notedetailstate(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textstyle = Theme.of(context).textTheme.titleLarge!;
    titlecontroller.text = note.title;
    disccontroller.text = note.description;

    return WillPopScope(
        onWillPop: () async => movetolastscreen(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                movetolastscreen();
              },
            ),
          ),
          body: Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
                left: 10.0,
                right: 10.0,
              ),
              child: ListView(
                children: <Widget>[
                  //first element
                  ListTile(
                    title: DropdownButton(
                      items: _priorities.map(
                        (String dropdownstringitem) {
                          return DropdownMenuItem<String>(
                            value: dropdownstringitem,
                            child: Text(dropdownstringitem),
                          );
                        },
                      ).toList(),
                      style: textstyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (String? valueselectedbyuser) {
                        setState(() {
                          debugPrint('$valueselectedbyuser');
                          updatePriorityAsInt(valueselectedbyuser);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextField(
                      controller: titlecontroller,
                      style: textstyle,
                      onChanged: (value) {
                        debugPrint("no change");
                        updateTitle();
                      },
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textstyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ),

                  // second element
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextField(
                      controller: disccontroller,
                      style: textstyle,
                      onChanged: (value) {
                        debugPrint("no change");
                        updateDescription();
                      },
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textstyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                debugPrint('save');
                                _save();
                              });
                            },
                            child: const Text('Save'),
                          ),
                        ),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                debugPrint('Delete');
                                _delete();
                              });
                            },
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ));
  }

  movetolastscreen() {
    Navigator.pop(context);
  }

  // Convert the String priority in the form of integer before saving it to Database
  updatePriorityAsInt(String? value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String? getPriorityAsString(int value) {
    String? priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }

    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titlecontroller.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = disccontroller.text;
  }

  // Save data to database
  void _save() async {
    movetolastscreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
      debugPrint('Note saved');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    movetolastscreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id!);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
