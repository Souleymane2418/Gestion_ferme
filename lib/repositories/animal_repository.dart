import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/animal.dart';

class AnimalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Animal>> getAll({EspeceAnimal? espece, StatutAnimal? statut}) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <Object?>[];
    if (espece != null) {
      where.add('espece = ?');
      args.add(espece.name);
    }
    if (statut != null) {
      where.add('statut = ?');
      args.add(statut.name);
    }
    final rows = await db.query(
      'animaux',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'maj_le DESC',
    );
    return rows.map(Animal.fromMap).toList();
  }

  Future<Animal?> getById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('animaux', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Animal.fromMap(rows.first);
  }

  Future<void> insert(Animal animal) async {
    final db = await _dbHelper.database;
    await db.insert('animaux', animal.toMap());
  }

  Future<void> update(Animal animal) async {
    final db = await _dbHelper.database;
    await db.update('animaux', animal.toMap(),
        where: 'id = ?', whereArgs: [animal.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('animaux', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count({StatutAnimal? statut}) async {
    final db = await _dbHelper.database;
    final res = statut != null
        ? await db.rawQuery(
            'SELECT COUNT(*) AS c FROM animaux WHERE statut = ?', [statut.name])
        : await db.rawQuery('SELECT COUNT(*) AS c FROM animaux');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<Map<EspeceAnimal, int>> countByEspece() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
        'SELECT espece, COUNT(*) AS c FROM animaux WHERE statut = ? GROUP BY espece',
        [StatutAnimal.actif.name]);
    final result = <EspeceAnimal, int>{};
    for (final r in rows) {
      result[EspeceAnimal.fromString(r['espece'] as String)] = r['c'] as int;
    }
    return result;
  }
}
import '../database/database_helper.dart';
import '../models/animal.dart';

class AnimalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Animal>> getAll({EspeceAnimal? espece, StatutAnimal? statut}) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <Object?>[];
    if (espece != null) {
      where.add('espece = ?');
      args.add(espece.name);
    }
    if (statut != null) {
      where.add('statut = ?');
      args.add(statut.name);
    }
    final rows = await db.query(
      'animaux',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'maj_le DESC',
    );
    return rows.map(Animal.fromMap).toList();
  }

  Future<Animal?> getById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('animaux', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Animal.fromMap(rows.first);
  }

  Future<void> insert(Animal animal) async {
    final db = await _dbHelper.database;
    await db.insert('animaux', animal.toMap());
  }

  Future<void> update(Animal animal) async {
    final db = await _dbHelper.database;
    await db.update('animaux', animal.toMap(),
        where: 'id = ?', whereArgs: [animal.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('animaux', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count({StatutAnimal? statut}) async {
    final db = await _dbHelper.database;
    final res = statut != null
        ? await db.rawQuery(
            'SELECT COUNT(*) AS c FROM animaux WHERE statut = ?', [statut.name])
        : await db.rawQuery('SELECT COUNT(*) AS c FROM animaux');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<Map<EspeceAnimal, int>> countByEspece() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
        'SELECT espece, COUNT(*) AS c FROM animaux WHERE statut = ? GROUP BY espece',
        [StatutAnimal.actif.name]);
    final result = <EspeceAnimal, int>{};
    for (final r in rows) {
      result[EspeceAnimal.fromString(r['espece'] as String)] = r['c'] as int;
    }
    return result;
  }
}
