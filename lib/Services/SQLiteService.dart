import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDatabase extends ChangeNotifier {
  Database _db;

  Future initialDatabase(userId) async {
    this._db = await openDatabase('authentication.db');

    await this._db.transaction((txn) async {
      await txn.rawQuery('''CREATE TABLE IF NOT EXISTS users (
                                      id INTEGER PRIMARY KEY,
                                      userid TEXT NOT NULL
                                      )''');
    });
    await this._db.transaction((txn) async {
      await txn.rawInsert(
      '''INSERT INTO users(id, userid) VALUES(1, "${userId}") ON CONFLICT(id) DO UPDATE SET userid="${userId}"''');
    });
  }

  Future getCurrentUserId() async {
    this._db = await openDatabase('authentication.db');
    List<Map<String, dynamic>> tmp;
    await this._db.transaction((txn)async{
      tmp = await txn.rawQuery('''
        SELECT * FROM users
      ''');
    });
    return tmp;
  }
}

//
//// open the database
//Database database = await openDatabase(path, version: 1,
//onCreate: (Database db, int version) async {
//// When creating the db, create the table
//await db.execute(
//'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
//});
//
//// Insert some records in a transaction
//await database.transaction((txn) async {
//int id1 = await txn.rawInsert(
//'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
//print('inserted1: $id1');
//int id2 = await txn.rawInsert(
//'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
//['another name', 12345678, 3.1416]);
//print('inserted2: $id2');
//});
//
//// Update some record
//int count = await database.rawUpdate(
//'UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',
//['updated name', '9876', 'some name']);
//print('updated: $count');
//
//// Get the records
//List<Map> list = await database.rawQuery('SELECT * FROM Test');
//List<Map> expectedList = [
//  {'name': 'updated name', 'id': 1, 'value': 9876, 'num': 456.789},
//  {'name': 'another name', 'id': 2, 'value': 12345678, 'num': 3.1416}
//];
//print(list);
//print(expectedList);
//assert(const DeepCollectionEquality().equals(list, expectedList));
//
//// Count the records
//count = Sqflite
//    .firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM Test'));
//assert(count == 2);
//
//// Delete a record
//count = await database
//    .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
//assert(count == 1);
//
//// Close the database
//await database.close();
