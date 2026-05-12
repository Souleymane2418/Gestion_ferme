import 'package:flutter/foundation.dart';
import '../models/reproduction.dart';
import '../repositories/reproduction_repository.dart';

class ReproductionProvider extends ChangeNotifier {
  final ReproductionRepository _repo = ReproductionRepository();

  List<Reproduction> _entrees = [];
  List<Reproduction> _misesBasAVenir = [];
  bool _loading = false;

  List<Reproduction> get entrees => _entrees;
  List<Reproduction> get misesBasAVenir => _misesBasAVenir;
  bool get loading => _loading;

  Future<void> charger({String? femelleId}) async {
    _loading = true;
    notifyListeners();
    _entrees = await _repo.getAll(femelleId: femelleId);
    _misesBasAVenir = await _repo.getMisesBasAVenir();
    _loading = false;
    notifyListeners();
  }

  Future<void> ajouter(Reproduction r) async {
    await _repo.insert(r);
    await charger();
  }

  Future<void> modifier(Reproduction r) async {
    await _repo.update(r);
    await charger();
  }

  Future<void> supprimer(String id) async {
    await _repo.delete(id);
    await charger();
  }
}
