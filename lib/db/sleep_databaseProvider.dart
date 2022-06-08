/* Glucose event database status management is used in conjunction with the models medium data model bpDBModel */
import 'package:bp_notepad/models/sleepDBModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SleepDataBaseProvider {
  static const String TABLE_NAME = 'sleepDB';
  static const String COLUMN_ID = "id";
  static const String COLUMN_TIME = 'date';
  static const String COLUMN_SLEEP = 'sleep';
  static const String COLUMN_STATE = 'state';

  SleepDataBaseProvider._();
  static final SleepDataBaseProvider db = SleepDataBaseProvider._();

  Database _database;

  //get database is written as getter in flutter
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await createDatabase();
    return _database;
  }

  Future<Database> createDatabase() async {
    //Get the default databases location
    String dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'sleepDB.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        print('CREATING sleepDB table');
        await database.execute("CREATE TABLE $TABLE_NAME ("
            "$COLUMN_ID INTEGER PRIMARY KEY,"
            "$COLUMN_TIME TEXT,"
            "$COLUMN_SLEEP REAL,"
            "$COLUMN_STATE INTEGER"
            ")");
      },
    );
  }

  Future<List> getGraphData() async {
    List dataList = [];
    final db = await database;
    var datas = await db.query(
      TABLE_NAME,
      columns: [COLUMN_SLEEP],
    );
    datas.forEach((element) {
      SleepDB sleepDB = SleepDB.fromMap(element);
      dataList.add(sleepDB.sleep);
    });
    return dataList;
  }

  Future<List<SleepDB>> getData() async {
    final db = await database;

    var datas = await db.query(
      TABLE_NAME,
      columns: [COLUMN_ID, COLUMN_TIME, COLUMN_SLEEP, COLUMN_STATE],
    );

    List<SleepDB> dataList = [];

    datas.forEach((element) {
      SleepDB sleepDB = SleepDB.fromMap(element);

      dataList.add(sleepDB);
    });

    return dataList.reversed.toList(); //Inverted List for easy viewing
  }

  Future<SleepDB> insert(SleepDB sleepDB) async {
    final db = await database;
    sleepDB.id = await db.insert(TABLE_NAME, sleepDB.toMap());
    return sleepDB;
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      TABLE_NAME,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

// SQLite has the following five data types:
// 1.NULL: null value.
// 2.INTEGER: Signed integer, depending on the range of stored numbers.
// 3. REAL: floating point number, stored as 8-byte IEEE floating point number.
// 4.TEXT: String text. (String)
// 5.BLOB: Binary object.
