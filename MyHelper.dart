import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'Movies.dart';

class MyHelper {
//1- create object from MyHelper
  static MyHelper helper;

  MyHelper._getInstance();

  factory MyHelper() {
    if (helper == null) {
      return MyHelper._getInstance();
    } else {
      return helper;
    }
  }

  static Database _database;

  //2- define constants
  static String db_name = 'movies.db';
  static String table_name = 'movies';
  static String col_id = 'id';
  static String col_title = 'title';
  static String col_popularity = 'popularity';
  static String col_overview = 'overview';
  static String col_releaseDate = 'releasedate';

  //3- create object from datbase
  Future<Database> get database async {
    if (_database != null)
      return _database;
    else
      return intializeDb();
  }

  Future<Database> intializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    var path = join(dir.path, db_name);
    return openDatabase(path, version: 1, onCreate: createTable);
  }

//create table
  static void createTable(Database db, int version) {
    //create table mytable (id integer primary key autoincrement, text text)
    String sql = '''create table $table_name (
    $col_id integer primary key, 
    $col_title text,
    $col_popularity float,
    $col_overview text,
    $col_releaseDate text
    )''';
    db.execute(sql);
  }

//insert operation
  insertIntoTable(Movies n) async {
    //values => Map<String,dynamic>
    var db = await this.database;
    db.insert(table_name, n.ConvertToMap());
  }

//select operation
  Future<List<Map<String, dynamic>>> selectFromTable() async {
    var db = await database;
    return db.rawQuery("select * from $table_name");
  }

  Future<List<Movies>> getMovies() async {
    var listOfMap = await selectFromTable();
    List<Movies> movies = List();
    for (int i = 0; i < listOfMap.length; i++) {
      movies.add(Movies.ConvertFromMap(listOfMap[i]));
    }
    return movies;
  }

   deleteUser(int id) async {
    var dbClient = await database;

     await dbClient.delete(table_name,
        where: "$col_id = ?", whereArgs: [id]);
  }
}
