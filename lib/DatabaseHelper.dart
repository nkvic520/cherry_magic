import 'package:cherry_magic/fans.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper.internal();

  factory DbHelper() => _instance;

  final String tableName = "Fans";

  final String columnId = "id";
  final String columnMember = "Member";
  final String columnRecordTime = "RecordTime";

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DbHelper.internal();

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'cherryMagic.db');
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  //创建数据库表
  void _onCreate(Database db, int version) async {
    await db.execute("create table $tableName("
        "$columnId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$columnMember INTEGER,"
        '$columnRecordTime TEXT'
        " )");
    print("Table is created");
  }

//插入
  Future<int> saveItem(Fans fans) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", fans.toJson());
    print(fans.toJson());
    return res;
  }

  //查询
  Future<List> getTotalList() async {
    var dbClient = await db;
    var result = await dbClient
        .query(tableName, columns: [columnId, columnMember, columnRecordTime]);
    List<Fans> fans = [];
    result.forEach((item) => fans.add(Fans.fromJson(item)));
    return fans;
  }

  //查询总数
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

  //清空数据
  Future<int> clear() async {
    var dbClient = await db;
    return await dbClient.delete(tableName);
  }

  //关闭
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
