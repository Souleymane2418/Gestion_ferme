import '../database/database_helper.dart';
import '../models/sante.dart';

class SanteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Sante>> getAll({String? animalId}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'sante',
      where: animalId != null ? 'animal_id = ?' : null,
      whereArgs: animalId != null ? [animalId] : null,
      orderBy: 'date DESC',
    );
    return rows.map(Sante.fromMap).toList();
  }

  Future<List<Sante>> getRappelsAVenir({int joursMax = 30}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final limit = now.add(Duration(days: joursMax));
    final rows = await db.query(
      'sante',
      where: 'prochain_rappel IS NOT NULL AND prochain_rappel BETWEEN ? AND ?',
      whereArgs: [now.toIso8601String(), limit.toIso8601String()],
      orderBy: 'prochain_rappel ASC',
    );
    return rows.map(Sante.fromMap).toList();
  }

  Future<void> insert(Sante sante) async {
    final db = await _dbHelper.database;
    await db.insert('sante', sante.toMap());
  }

  Future<void> update(Sante sante) async {
    final db = await _dbHelper.database;
    await db.update('sante', sante.toMap(),
        where: 'id = ?', whereArgs: [sante.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('sante', where: 'id = ?', whereArgs: [id]);
  }
}
