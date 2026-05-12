import 'package:flutter/foundation.dart';
import '../models/production.dart';
import '../repositories/production_repository.dart';

class ProductionProvider extends ChangeNotifier {
  final ProductionRepository _repo = ProductionRepository();

  List<Production> _entrees = [];
  bool _loading = false;
  TypeProduction? _filtreType;

  List<Production> get entrees => _entrees;
  bool get loading => _loading;
  TypeProduction? get filtreType => _filtreType;

  Future<void> charger() async {
    _loading = true;
    notifyListeners();
    _entrees = await _repo.getAll(type: _filtreType);
    _loading = false;
    notifyListeners();
  }

  void definirFiltreType(TypeProduction? type) {
    _filtreType = type;
    charger();
  }

  Future<double> totalParType(TypeProduction type, {DateTime? depuis}) =>
      _repo.totalParType(type, depuis: depuis);

  Future<void> ajouter(Production p) async {
    await _repo.insert(p);
    await charger();
  }

  Future<void> modifier(Production p) async {
    await _repo.update(p);
    await charger();
  }

  Future<void> supprimer(String id) async {
    await _repo.delete(id);
    await charger();
  }
}
