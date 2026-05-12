import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/production.dart';

class ProductionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Production>> getAll({TypeProduction? type, String? animalId}) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <Object?>[];
    if (type != null) {
      where.add('type = ?');
      args.add(type.name);
    }
    if (animalId != null) {
      where.add('animal_id = ?');
      args.add(animalId);
    }
    final rows = await db.query(
      'production',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'date DESC',
    );
    return rows.map(Production.fromMap).toList();
  }

  Future<double> totalParType(TypeProduction type, {DateTime? depuis}) async {
    final db = await _dbHelper.database;
    final args = <Object?>[type.name];
    var sql =
        'SELECT COALESCE(SUM(quantite), 0) AS total FROM production WHERE type = ?';
    if (depuis != null) {
      sql += ' AND date >= ?';
      args.add(depuis.toIso8601String());
    }
    final res = await db.rawQuery(sql, args);
    final total = res.first['total'];
    return (total as num?)?.toDouble() ?? 0.0;
  }

  Future<void> insert(Production p) async {
    final db = await _dbHelper.database;
    await db.insert('production', p.toMap());
  }

  Future<void> update(Production p) async {
    final db = await _dbHelper.database;
    await db.update('production', p.toMap(),
        where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('production', where: 'id = ?', whereArgs: [id]);
  }
}
