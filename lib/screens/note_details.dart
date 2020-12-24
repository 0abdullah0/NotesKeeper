import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String title;
  final Note note;
  NoteDetail(this.note,this.title);

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorties=["High","Low"];
  TextEditingController titleController=TextEditingController();
  TextEditingController descriptionController=TextEditingController();
  DatabaseHelper helper= DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle=Theme.of(context).textTheme.title;
    titleController.text=widget.note.title;
    descriptionController.text=widget.note.description;
    return WillPopScope(
      onWillPop:(){
        Navigator.pop(context);
      } ,//Handler,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 15.0,left: 10.0,right: 10.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton(
                    items: _priorties.map((String dropItem){
                      return DropdownMenuItem<String>(
                        value: dropItem,
                        child: Text(dropItem),
                      );
                    }).toList(),
                    style: textStyle ,
                    value: toIntPriority(widget.note.priority),
                    onChanged:(value){
                      setState(() {
                        debugPrint("user selected $value");
                        toStringPriority(value);
                      });
                    }
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top:15.0,bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value){
                    debugPrint("change!");
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: "title",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top:15.0,bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value){
                    debugPrint("change!");
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: "description",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:15.0,bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                          onPressed:(){
                            setState(() {
                              debugPrint("saved");
                              _save();
                            });
                          },
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text("Save",textScaleFactor: 1.5,),
                      ),
                    ),
                    Container(width: 5.0,),
                    Expanded(
                      child: RaisedButton(
                        onPressed:(){
                          setState(() {
                            debugPrint("deleted");
                            _delete();
                          });
                        },
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text("Delete",textScaleFactor: 1.5,),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  void _showAlertDialog(String title,String message){
    AlertDialog alertDialog=AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context:context,
      builder: (_)=>alertDialog
    );
  }
  void _delete()async{
    if(widget.note.id==null)
      {
        _showAlertDialog("status","no note to delete");
        return;
      }
    int result=await helper.deleteNote(widget.note.id);
    if(result!=0){
      _showAlertDialog("status","deleted sucessfuly");
    }else{
      _showAlertDialog("status","Error occured");
    }

    Navigator.pop(context,true);
  }
  void _save()async{
    int result;
    widget.note.date=DateFormat.yMMMd().format(DateTime.now());
    if(widget.note.title!=null) //case1 update
      {
        result=await helper.updateNote(widget.note);
      }else{ //case2 insert
        result=await helper.insertNote(widget.note);
    }
    if(result!=0) //success
      {
        _showAlertDialog('status','Saved Sucessfuly');
      }
    else{
      _showAlertDialog('status','Problem Appeared');
    }

    Navigator.pop(context,true);
  }
  void updateTitle(){
    widget.note.title=titleController.text;
  }
  void updateDescription(){
    widget.note.description=titleController.text;
  }
  void toStringPriority(String value){
    switch(value){
      case "High":
        widget.note.priority=1;break;
      case "Low":
        widget.note.priority=2;break;

    }
  }
  String toIntPriority(int value){
    String priority;
    switch(value){
      case 1:
        priority=_priorties[0];break;
      case 2:
        priority=_priorties[1];break;
    }
    return priority;
  }
}
