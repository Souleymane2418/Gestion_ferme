import '../database/database_helper.dart';
import '../models/reproduction.dart';

class ReproductionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Reproduction>> getAll({String? femelleId}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'reproduction',
      where: femelleId != null ? 'femelle_id = ?' : null,
      whereArgs: femelleId != null ? [femelleId] : null,
      orderBy: 'date DESC',
    );
    return rows.map(Reproduction.fromMap).toList();
  }

  Future<List<Reproduction>> getMisesBasAVenir({int joursMax = 30}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final limit = now.add(Duration(days: joursMax));
    final rows = await db.query(
      'reproduction',
      where: 'date_attendue IS NOT NULL AND date_attendue BETWEEN ? AND ?',
      whereArgs: [now.toIso8601String(), limit.toIso8601String()],
      orderBy: 'date_attendue ASC',
    );
    return rows.map(Reproduction.fromMap).toList();
  }

  Future<void> insert(Reproduction r) async {
    final db = await _dbHelper.database;
    await db.insert('reproduction', r.toMap());
  }

  Future<void> update(Reproduction r) async {
    final db = await _dbHelper.database;
    await db.update('reproduction', r.toMap(),
        where: 'id = ?', whereArgs: [r.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('reproduction', where: 'id = ?', whereArgs: [id]);
  }
}
