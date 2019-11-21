import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contatoTable = "contatoTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String foneColumn = "foneColumn";
final String imgColumn = "imgColumn";

class ContatoHelper {
  static final ContatoHelper _instancia = ContatoHelper.internal();

  factory ContatoHelper() => _instancia;

  ContatoHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db == null) _db = await initDb();

    return _db;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contatos.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contatoTable ($idColumn INTEGER PRIMARY KEY, "
          "$nameColumn TEXT, $emailColumn TEXT, $foneColumn TEXT, $imgColumn TEXT)");
    });
  }

  Future<Contato> saveContato(Contato contato) async {
    Database dbContato = await db;
    contato.id = await dbContato.insert(contatoTable, contato.toMap());
    return contato;
  }

  Future<Contato> getContato(int id) async {
    Database dbContato = await db;
    List<Map> maps = await dbContato.query(contatoTable,
        columns: [idColumn, nameColumn, emailColumn, foneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0)
      return Contato.fromMap(maps.first);
    else
      return null;
  }

  Future<int> deleteContato(int id) async {
    Database dbContato = await db;
    return await dbContato
        .delete(contatoTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContato(Contato contato) async {
    Database dbContato = await db;
    return await dbContato.update(contatoTable, contato.toMap(),
        where: "$idColumn = ?", whereArgs: [contato.id]);
  }

  Future<List<Contato>> getAllContatos() async{
    Database dbContato = await db;
    List listMap = await dbContato.rawQuery("SELECT * FROM $contatoTable");
    List<Contato> lista = List();
    for(Map m in listMap)
      lista.add(Contato.fromMap(m));

    return lista;
  }

 Future<int> getNumber() async{
    Database dbContato = await db;
    return Sqflite.firstIntValue(await dbContato.rawQuery("SELECT COUNT(*) FROM $contatoTable"));
  }

  Future close()async{
    Database dbContato = await db;
    dbContato.close();
  }
}

class Contato {
  int id;
  String name;
  String email;
  String fone;
  String img;

  Contato(){

  }
  Contato.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    fone = map[foneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      foneColumn: fone,
      imgColumn: img
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contato(id: $id, name: $name, email: $email, fone: $fone, imagem: $img";
  }
}
