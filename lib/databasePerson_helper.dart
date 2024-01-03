import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:group_name/databasePerson_helper.dart';

class DatabasePersonHelper{
  static const _databaseName = "PersonNameDB.db";
  static const _databaseVersion = 1; // onUpgrade

  static const personNameTable = 'person_name_table';

  static const columnId = '_id';
  static const columnPersonName = '_personName';

  late Database _db;

  Future<void> initialization() async {
    print('initialization');
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, _databaseName);

    print('Path : $path');

    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database database, int version) async {
    print('_onCreate');
    await database.execute('''
        CREATE TABLE $personNameTable (
          $columnId INTEGER PRIMARY KEY,
          $columnPersonName TEXT
        )
    ''');
  }

  _onUpgrade(Database database, int oldVersion, int newVersion) async{
    print('_onUpgrade');
    await database.execute('drop table $personNameTable');
    _onCreate(database, newVersion);
  }

  Future<int> insertPersonName(Map<String, dynamic> row) async{
    return await _db.insert(personNameTable, row);
  }

  Future<List<Map<String, dynamic>>> getPersonNames() async {
    // select * from person_name_table;
    return await _db.query(personNameTable);
  }

  readDataById(groupNameId) async {
    return await _db.query(
      personNameTable,
      where: '_id =? ',
      whereArgs: [groupNameId],
    );
  }

  Future<int> updatePersonName(Map<String, dynamic> row) async{
    int id = row[columnId];
    return await _db .update(
      personNameTable,
      row,
      where: '$columnId = ?',
      whereArgs: [id], );
  }

  Future<int> deletePersonName(int id) async{
    return await _db.delete(
      personNameTable,
      where: '$columnId =?',
      whereArgs: [id],);
  }

}