import 'package:flutter/foundation.dart';
import '../models/transaction.dart' as model;
import '../repositories/transaction_repository.dart';

class FinanceProvider extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();

  List<model.Transaction> _transactions = [];
  bool _loading = false;
  double _totalRevenus = 0;
  double _totalDepenses = 0;

  List<model.Transaction> get transactions => _transactions;
  bool get loading => _loading;
  double get totalRevenus => _totalRevenus;
  double get totalDepenses => _totalDepenses;
  double get benefice => _totalRevenus - _totalDepenses;

  Future<void> charger({DateTime? depuis, DateTime? jusqua}) async {
    _loading = true;
    notifyListeners();
    _transactions = await _repo.getAll(depuis: depuis, jusqua: jusqua);
    _totalRevenus = await _repo.totalParType(model.TypeTransaction.revenu,
        depuis: depuis, jusqua: jusqua);
    _totalDepenses = await _repo.totalParType(model.TypeTransaction.depense,
        depuis: depuis, jusqua: jusqua);
    _loading = false;
    notifyListeners();
  }

  Future<void> ajouter(model.Transaction t) async {
    await _repo.insert(t);
    await charger();
  }

  Future<void> modifier(model.Transaction t) async {
    await _repo.update(t);
    await charger();
  }

  Future<void> supprimer(String id) async {
    await _repo.delete(id);
    await charger();
  }
}
