import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notodo_app/modal/nodo_item.dart';

class DatabaseHelper{
  final String tableNotoDo = "notoDoTable";
  final String columnId = "id";
  final String columnNote = "itemName";
  final String columnDate = "dateCreated";

  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async{
    if(_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "maindb.db");
    var ourdb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourdb;
  }

  void _onCreate(Database db, int version) async{
    await db.execute(
        "CREATE TABLE $tableNotoDo($columnId INTEGER PRIMARY KEY, $columnNote TEXT, $columnDate INTEGER)"
    );
  }

  //Insertion
  Future<int> saveNote(NoDoItem item) async{
    var dbClient = await db;
    int res = await dbClient.insert(tableNotoDo, item.toMap());
    return res;
  }

  //Get Users
  Future<List> getAllNotes() async{
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableNotoDo");
    return result.toList();
  }

  Future<int> getCount() async{
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery(
            "SELECT COUNT(*) FROM $tableNotoDo"
        )
    );
  }

  Future<NoDoItem> getNote(int id) async{
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableNotoDo WHERE $columnId = $id");
    if(result.length == 0) return null;
    return new NoDoItem.fromMap(result.first);
  }

  Future<int> deleteNote(int id) async{
    var dbClient = await db;
    return await dbClient.delete(tableNotoDo, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<int> updateNote(NoDoItem item) async{
    var dbClient = await db;
    return await dbClient.update(tableNotoDo,
        item.toMap(), where: "$columnId = ?", whereArgs: [item.id]);
  }

  Future close() async{
    var dbClient = await db;
    return dbClient.close();
  }
}