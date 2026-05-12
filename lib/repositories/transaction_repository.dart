import '../database/database_helper.dart';
import '../models/transaction.dart' as model;

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<model.Transaction>> getAll({
    model.TypeTransaction? type,
    DateTime? depuis,
    DateTime? jusqua,
  }) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <Object?>[];
    if (type != null) {
      where.add('type = ?');
      args.add(type.name);
    }
    if (depuis != null) {
      where.add('date >= ?');
      args.add(depuis.toIso8601String());
    }
    if (jusqua != null) {
      where.add('date <= ?');
      args.add(jusqua.toIso8601String());
    }
    final rows = await db.query(
      'transactions',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'date DESC',
    );
    return rows.map(model.Transaction.fromMap).toList();
  }

  Future<double> totalParType(model.TypeTransaction type,
      {DateTime? depuis, DateTime? jusqua}) async {
    final db = await _dbHelper.database;
    final args = <Object?>[type.name];
    var sql =
        'SELECT COALESCE(SUM(montant), 0) AS total FROM transactions WHERE type = ?';
    if (depuis != null) {
      sql += ' AND date >= ?';
      args.add(depuis.toIso8601String());
    }
    if (jusqua != null) {
      sql += ' AND date <= ?';
      args.add(jusqua.toIso8601String());
    }
    final res = await db.rawQuery(sql, args);
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> insert(model.Transaction t) async {
    final db = await _dbHelper.database;
    await db.insert('transactions', t.toMap());
  }

  Future<void> update(model.Transaction t) async {
    final db = await _dbHelper.database;
    await db.update('transactions', t.toMap(),
        where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
