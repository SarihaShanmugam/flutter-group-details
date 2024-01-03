import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{
  static const _databaseName = "GroupNameDB.db";
  static const _databaseVersion = 1;

  static const groupNameTable = 'group_name_table';

  static const columnId = '_id';
  static const columnGroupName = '_groupName';

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
        CREATE TABLE $groupNameTable (
          $columnId INTEGER PRIMARY KEY,
          $columnGroupName TEXT
        )
    ''');
  }

  _onUpgrade(Database database, int oldVersion, int newVersion) async{
    print('_onUpgrade');
    await database.execute('drop table $groupNameTable');
    _onCreate(database, newVersion);
  }

  Future<int> insertGroupName(Map<String, dynamic> row) async{
    return await _db .insert(groupNameTable, row);
  }

  Future<List<Map<String, dynamic>>> getGroupNames() async {
    return await _db.query(groupNameTable);
  }

  readDataById(groupNameId) async {
    return await _db.query(
      groupNameTable,
      where: '_id =? ',
      whereArgs: [groupNameId],
    );
  }

  Future<int> updateGroupName(Map<String, dynamic> row) async{
    int id = row[columnId];
    return await _db .update(
      groupNameTable,
      row,
      where: '$columnId = ?',
      whereArgs: [id], );
  }

  Future<int> deleteGroupName(int id) async{
    return await _db.delete(
      groupNameTable,
      where: '$columnId =?',
      whereArgs: [id],);
  }

}