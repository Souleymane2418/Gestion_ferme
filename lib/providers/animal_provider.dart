import 'package:flutter/foundation.dart';
import '../models/animal.dart';
import '../repositories/animal_repository.dart';

class AnimalProvider extends ChangeNotifier {
  final AnimalRepository _repo = AnimalRepository();

  List<Animal> _animaux = [];
  bool _loading = false;
  EspeceAnimal? _filtreEspece;

  List<Animal> get animaux => _animaux;
  bool get loading => _loading;
  EspeceAnimal? get filtreEspece => _filtreEspece;

  int get nbActifs =>
      _animaux.where((a) => a.statut == StatutAnimal.actif).length;

  Future<void> chargerAnimaux() async {
    _loading = true;
    notifyListeners();
    _animaux = await _repo.getAll(espece: _filtreEspece);
    _loading = false;
    notifyListeners();
  }

  void definirFiltreEspece(EspeceAnimal? espece) {
    _filtreEspece = espece;
    chargerAnimaux();
  }

  Future<void> ajouter(Animal a) async {
    await _repo.insert(a);
    await chargerAnimaux();
  }

  Future<void> modifier(Animal a) async {
    await _repo.update(a);
    await chargerAnimaux();
  }

  Future<void> supprimer(String id) async {
    await _repo.delete(id);
    await chargerAnimaux();
  }

  Future<Animal?> obtenir(String id) => _repo.getById(id);

  Future<Map<EspeceAnimal, int>> repartitionParEspece() =>
      _repo.countByEspece();
}
