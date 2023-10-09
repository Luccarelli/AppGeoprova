import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = 'app_database.db';
  static final _databaseVersion = 1;

  static final table = 'login_table';

  static final columnId = '_id';
  static final columnLogin = 'login';
  static final columnPassword = 'password';

  // Fazemos o Singleton da classe para evitar múltiplas instâncias do banco de dados.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Referência para o banco de dados.
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnLogin TEXT NOT NULL,
            $columnPassword TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Pode ser útil no futuro para consultar um login específico, mas para o propósito atual,
  // podemos usar apenas a consulta de todas as linhas.
  // Future<Map<String, dynamic>> queryLogin(String login) async {
  //   Database db = await instance.database;
  //   return await db.query(table, where: '$columnLogin = ?', whereArgs: [login]);
  // }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}
