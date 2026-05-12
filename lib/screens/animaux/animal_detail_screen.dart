import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../models/sante.dart';
import '../../models/reproduction.dart';
import '../../providers/animal_provider.dart';
import '../../repositories/sante_repository.dart';
import '../../repositories/reproduction_repository.dart';
import 'animal_form_screen.dart';

class AnimalDetailScreen extends StatefulWidget {
  final String animalId;
  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  Animal? _animal;
  List<Sante> _sante = [];
  List<Reproduction> _repro = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() => _loading = true);
    final a = await context.read<AnimalProvider>().obtenir(widget.animalId);
    final s = await SanteRepository().getAll(animalId: widget.animalId);
    final r = await ReproductionRepository().getAll(femelleId: widget.animalId);
    if (!mounted) return;
    setState(() {
      _animal = a;
      _sante = s;
      _repro = r;
      _loading = false;
    });
  }

  Future<void> _supprimer() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cet animal ?'),
        content: const Text(
            'Cette action est irréversible. Tous les enregistrements liés (santé, reproduction) seront aussi supprimés.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AnimalProvider>().supprimer(widget.animalId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final a = _animal;
    if (a == null) {
      return const Scaffold(
        body: Center(child: Text('Animal introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(a.nom),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AnimalFormScreen(animal: a),
              ));
              _charger();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer',
            onPressed: _supprimer,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informations',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Divider(),
                  _ligne('Identifiant', a.identifiant),
                  _ligne('Espèce', a.espece.label),
                  _ligne('Sexe', a.sexe.label),
                  if (a.race != null) _ligne('Race', a.race!),
                  if (a.dateNaissance != null)
                    _ligne('Naissance', dateFmt.format(a.dateNaissance!)),
                  if (a.ageEnMois != null)
                    _ligne('Âge', '${a.ageEnMois} mois'),
                  if (a.poidsKg != null)
                    _ligne('Poids', '${a.poidsKg} kg'),
                  _ligne('Statut', a.statut.label),
                  if (a.notes != null && a.notes!.isNotEmpty)
                    _ligne('Notes', a.notes!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Historique sanitaire (${_sante.length})',
              style: Theme.of(context).textTheme.titleMedium),
          if (_sante.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Aucun enregistrement sanitaire.'),
            )
          else
            ..._sante.map((s) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: Text(s.libelle),
                    subtitle: Text(
                        '${s.type.label} · ${dateFmt.format(s.date)}'),
                  ),
                )),
          const SizedBox(height: 16),
          if (a.sexe == SexeAnimal.femelle) ...[
            Text('Reproduction (${_repro.length})',
                style: Theme.of(context).textTheme.titleMedium),
            if (_repro.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Aucun enregistrement.'),
              )
            else
              ..._repro.map((r) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.favorite),
                      title: Text(r.type.label),
                      subtitle: Text(dateFmt.format(r.date)),
                    ),
                  )),
          ],
        ],
      ),
    );
  }

  Widget _ligne(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(valeur)),
        ],
      ),
    );
  }
}
