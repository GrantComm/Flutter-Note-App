import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import "package:notekeeperapp/screens/note_detail.dart";
import 'package:sqflite/sqflite.dart';
import 'package:notekeeperapp/utils/database_helper.dart';
import 'package:notekeeperapp/models/note.dart';
import 'dart:async';

class NoteDetail extends StatefulWidget{
   final String appBarTitle;
   final Note note;
  NoteDetail(this.note, this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteDetailState(this.note, this.appBarTitle);
  }

}

class NoteDetailState extends State<NoteDetail> {
  var _formKey = GlobalKey<FormState>();
  String appBarTitle;
  DatabaseHelper helper = DatabaseHelper();
  Note note;
  NoteDetailState(this.note, this.appBarTitle);
  static var _priorities = ["High", "Low"];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child:
      Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            moveToLastScreen();
          },
        )
      ),
      body: Form(
          key: _formKey,
          child:
        Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem){
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),

                    style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser){
                      setState(() {
                        debugPrint("User selected $valueSelectedByUser");
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                  child: TextFormField(
                    validator: (String value) {
                      if(value.isEmpty){
                        return "Cannot be empty";
                      }
                    },
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value){
                      debugPrint("Something changed in the title field");
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                  child: TextFormField(
                    validator: (String value) {
                      if(value.isEmpty){
                        return "Cannot be empty";
                      }
                    },
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value){
                      debugPrint("Something changed in the description field");
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: (){
                            setState(() {
                              if(_formKey.currentState.validate()) {
                                debugPrint("Save Button Clicked");
                                _save();
                              }
                            });
                          },
                        ),
                      ),

                      Container(width: 5.0,),

                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: (){
                            setState(() {
                              debugPrint("Delete Button Clicked");
                              _delete();
                            });
                          },
                        ),
                      )

                    ],
                  ),
                )
              ],
            )),
      )));
  }

void moveToLastScreen(){
    Navigator.pop(context, true);
}

void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
}

  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle(){
    note.title = titleController.text;
  }

  void updateDescription(){
    note.description = descriptionController.text;
  }

  void _save() async{
    moveToLastScreen();
    int result;
    note.date =  DateFormat.yMMMd().format(DateTime.now());
    if(note.id != null){
      result = await helper.updateNote(note);
    }else{
      result = await helper.insertNote(note);
    }

    if(result != 0){
      _showAlertDialog("Status", "Note successfully saved");
    }else{
      _showAlertDialog("Status", "Error saving note");
    }
  }


  void _delete() async{
    moveToLastScreen();
    if(note.id == null){
      _showAlertDialog("Status", "No Note deleted");
      return;
    }

    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlertDialog("Status", "Note successfully deleted");
    }else{
      _showAlertDialog("Status", "Error deleting note");
    }
  }

  void _showAlertDialog(String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }


}
