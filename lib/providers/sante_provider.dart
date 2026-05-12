import 'package:flutter/foundation.dart';
import '../models/sante.dart';
import '../repositories/sante_repository.dart';

class SanteProvider extends ChangeNotifier {
  final SanteRepository _repo = SanteRepository();

  List<Sante> _entrees = [];
  List<Sante> _rappels = [];
  bool _loading = false;

  List<Sante> get entrees => _entrees;
  List<Sante> get rappels => _rappels;
  bool get loading => _loading;

  Future<void> charger({String? animalId}) async {
    _loading = true;
    notifyListeners();
    _entrees = await _repo.getAll(animalId: animalId);
    _rappels = await _repo.getRappelsAVenir();
    _loading = false;
    notifyListeners();
  }

  Future<void> ajouter(Sante s) async {
    await _repo.insert(s);
    await charger();
  }

  Future<void> modifier(Sante s) async {
    await _repo.update(s);
    await charger();
  }

  Future<void> supprimer(String id) async {
    await _repo.delete(id);
    await charger();
  }
}
