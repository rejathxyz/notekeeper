import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/models/node.dart';
import 'package:notekeeper/utils/database_helper.dart';

class NoteData extends StatefulWidget{
  String appTitle;
  final Note note;
  NoteData(this.note,this.appTitle);
  @override
  State<StatefulWidget> createState() {
    return NoteDataState(this.note,this.appTitle);
  }
}

class NoteDataState extends State<NoteData>{
  String appTitle;
  Note note;
  var pad=18.0;
  var _formkey= GlobalKey<FormState>();
  NoteDataState(this.note, this.appTitle);
  DatabaseHelper helper = DatabaseHelper();
  static var _priorities=['High','Low'];
  TextEditingController titleController= TextEditingController();
  TextEditingController descriptionController= TextEditingController();
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle=Theme.of(context).textTheme.title;
    titleController.text=note.title;
    descriptionController.text=note.description;
    return WillPopScope(
      onWillPop: (){
        //write some code to control yhings when user press back button
        moveToLastScreen();
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(appTitle, textScaleFactor: 1.25,),
        leading: IconButton( icon: Icon(Icons.arrow_back),
        onPressed: (){

          moveToLastScreen();
        },)


      ),
      body: Form(key: _formkey, child: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0,right: 10.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.)
              ),
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem){
                  return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(dropDownStringItem),
                  );
              },
              ).toList(),
                style: textStyle,
                value: getPriorityAsString(note.priority),
                onChanged: (valueSelectedByUser){
                  setState(() {
                    debugPrint("User selected $valueSelectedByUser");
                    updatePriorityAsInt(valueSelectedByUser);
                  });
                }
            )),
            //second element
            Padding(
              padding: EdgeInsets.symmetric(vertical: pad),
              child: TextFormField(

                controller: titleController,
                validator: (String value){
                  // ignore: missing_return
                  if (value.isEmpty){
                    return 'Please enter Title';
                  }
                },
                style: textStyle,
                onChanged: (value){
                  debugPrint("someting changed in the title textfield");
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: textStyle,
                    errorStyle: TextStyle(
                        color: Colors.indigo,
                        fontSize: 15.0
                    ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9.0),
                  )
                ),
              ),
            ),
            //third element
            Padding(
              padding: EdgeInsets.symmetric(vertical: pad),
              child: TextFormField(
                controller: descriptionController,
                validator: (String value){
                  // ignore: missing_return
                  if (value.isEmpty){
                    return 'Please enter Descriptiom';
                  }
                },
                style: textStyle,
                onChanged: (value){
                  debugPrint("someting changed in the description textfield");
                  updateDescripton();
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    errorStyle: TextStyle(
                        color: Colors.indigo,
                        fontSize: 15.0
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                ),
              ),
            ),
            //fourth element
            Padding(
              padding: EdgeInsets.symmetric(vertical: pad),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Colors.white,
                      child: Text("Save", textScaleFactor: 1.5,),
                      onPressed: (){
                        debugPrint("Save button clicked");
                        if(_formkey.currentState.validate()) {
                          _save();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 5.0,),
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Colors.white,
                      child: Text("Delete", textScaleFactor: 1.5,),
                      onPressed: (){
                        debugPrint("Delete button clicked");
                        _delete();
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),)
    ));

  }
  //to last screen
  void moveToLastScreen(){
    Navigator.pop(context,true);
  }
  //convert string priority to int
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High': note.priority=1; break;
      case 'Low' : note.priority=2; break;
    }
  }

  //convert int priority to string
  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1: priority=_priorities[0]; break;
      case 2: priority=_priorities[1]; break;
    }
    return priority;
  }
  //update title changed to note
  void updateTitle(){
    note.title=titleController.text;
  }
  //update descriprion changed to note
  void updateDescripton(){
    note.description=descriptionController.text;
  }

  //delete from db
  void _delete() async{
    moveToLastScreen();
    //case 1 delete new note
    if(note.id == null){
      _showAlertDialogue('Status', 'There is an error');
      return;
    }
    //case 2 delete exixting note
    int result=await helper.deleteNote(note.id);
    if(result!=0){//succes
      _showAlertDialogue('Status','Note Deleted Successfullly');
    }
    else{//failure
      _showAlertDialogue('Status','Error Occured');
    }
  }

  //save to database
  void _save() async{
    moveToLastScreen();
    int result;
    note.date=DateFormat.yMMMd().format(DateTime.now());
    if(note.id != null){ //update operation
     result= await helper.updateNote(note);
    }
    else{//insert operation
      result= await helper.insertNote(note);

    }
    if(result!=0){//succes
      _showAlertDialogue('Status','Note Saved Successfullly');
    }
    else{//failure
      _showAlertDialogue('Status','Error Occured While Saving Note');
    }
  }
  void _showAlertDialogue(String title, String msg){
    AlertDialog alertDialog= AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_)=>alertDialog);
  }
}