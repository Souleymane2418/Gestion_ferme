import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/animal.dart';
import '../../providers/animal_provider.dart';

class AnimalFormScreen extends StatefulWidget {
  final Animal? animal;
  const AnimalFormScreen({super.key, this.animal});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifiantCtrl;
  late final TextEditingController _nomCtrl;
  late final TextEditingController _raceCtrl;
  late final TextEditingController _poidsCtrl;
  late final TextEditingController _notesCtrl;
  late EspeceAnimal _espece;
  late SexeAnimal _sexe;
  late StatutAnimal _statut;
  DateTime? _dateNaissance;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _identifiantCtrl = TextEditingController(text: a?.identifiant ?? '');
    _nomCtrl = TextEditingController(text: a?.nom ?? '');
    _raceCtrl = TextEditingController(text: a?.race ?? '');
    _poidsCtrl = TextEditingController(
        text: a?.poidsKg != null ? a!.poidsKg.toString() : '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');
    _espece = a?.espece ?? EspeceAnimal.bovin;
    _sexe = a?.sexe ?? SexeAnimal.femelle;
    _statut = a?.statut ?? StatutAnimal.actif;
    _dateNaissance = a?.dateNaissance;
  }

  @override
  void dispose() {
    _identifiantCtrl.dispose();
    _nomCtrl.dispose();
    _raceCtrl.dispose();
    _poidsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final res = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (res != null) setState(() => _dateNaissance = res);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AnimalProvider>();
    final now = DateTime.now();
    final poids = double.tryParse(_poidsCtrl.text.replaceAll(',', '.'));

    if (widget.animal == null) {
      final a = Animal(
        id: const Uuid().v4(),
        identifiant: _identifiantCtrl.text.trim(),
        nom: _nomCtrl.text.trim(),
        espece: _espece,
        race: _raceCtrl.text.trim().isEmpty ? null : _raceCtrl.text.trim(),
        sexe: _sexe,
        dateNaissance: _dateNaissance,
        poidsKg: poids,
        statut: _statut,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        creeLe: now,
        majLe: now,
      );
      await provider.ajouter(a);
    } else {
      final a = widget.animal!.copyWith(
        identifiant: _identifiantCtrl.text.trim(),
        nom: _nomCtrl.text.trim(),
        espece: _espece,
        race: _raceCtrl.text.trim().isEmpty ? null : _raceCtrl.text.trim(),
        sexe: _sexe,
        dateNaissance: _dateNaissance,
        poidsKg: poids,
        statut: _statut,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await provider.modifier(a);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animal == null ? 'Nouvel animal' : 'Modifier'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _identifiantCtrl,
              decoration: const InputDecoration(
                  labelText: 'Identifiant / Numéro de boucle *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nomCtrl,
              decoration: const InputDecoration(labelText: 'Nom *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EspeceAnimal>(
              value: _espece,
              decoration: const InputDecoration(labelText: 'Espèce'),
              items: EspeceAnimal.values
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.label)))
                  .toList(),
              onChanged: (v) => setState(() => _espece = v ?? _espece),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SexeAnimal>(
              value: _sexe,
              decoration: const InputDecoration(labelText: 'Sexe'),
              items: SexeAnimal.values
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) => setState(() => _sexe = v ?? _sexe),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _raceCtrl,
              decoration: const InputDecoration(labelText: 'Race'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _choisirDate,
              child: InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'Date de naissance'),
                child: Text(_dateNaissance != null
                    ? dateFmt.format(_dateNaissance!)
                    : 'Choisir une date'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _poidsCtrl,
              decoration: const InputDecoration(labelText: 'Poids (kg)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StatutAnimal>(
              value: _statut,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: StatutAnimal.values
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) => setState(() => _statut = v ?? _statut),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _enregistrer,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
