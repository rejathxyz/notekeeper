import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notekeeper/models/node.dart';
import 'dart:io';
import 'dart:async';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable='note_table';
  String colId='id';
  String colTitle='title';
  String colDescription='description';
  String coldDate='date';
  String colPriority='priority';
  DatabaseHelper._createInstance();
  factory DatabaseHelper(){
    if(_databaseHelper== null){
      _databaseHelper=DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }
  Future<Database> get database async{
    if(_database==null){
      _database= await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{
    //get the directory path for android and ios
    Directory directory=await getApplicationDocumentsDirectory();
    String path=directory.path + 'notes.db';
    //open/create db at given path
    var notesDatabase=await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }
  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $coldDate TEXT)');
  }

  //fetch operatiion
  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db=await this.database;
    //var result=db.rawQuery("SELECT * FROM $noteTable order by $colPriority ASC");
    var result = db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }
  //insert operation
  Future<int> insertNote(Note note) async{
    Database db=await this.database;
    var result=await db.insert(noteTable, note.toMap());
    return result;
  }
  //update opration
  Future<int> updateNote(Note note) async{
    Database db=await this.database;
    var result=await db.update(noteTable, note.toMap(), where: "$colId=?", whereArgs: [note.id]);
    return result;
  }
  //delete operation
  Future<int>  deleteNote(int id) async{
    Database db=await this.database;
    var result=await db.rawDelete('DELETE FROM $noteTable WHERE $colId=$id');
    return result;
  }
  //get number of objects in db
  Future<int> getCount() async{
    Database db=await this.database;
    List<Map<String, dynamic>> x=await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result= Sqflite.firstIntValue(x);
    return result;
  }
  //convert maplist to notelist
  Future<List<Note>> getNoteList() async{

    var noteMapList= await getNoteMapList();
    int count=noteMapList.length;
    List<Note> noteList= <Note>[];
    for(int i=0;i<count;i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}