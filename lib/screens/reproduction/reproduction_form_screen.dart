import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/animal.dart';
import '../../models/reproduction.dart';
import '../../providers/animal_provider.dart';
import '../../providers/reproduction_provider.dart';

class ReproductionFormScreen extends StatefulWidget {
  const ReproductionFormScreen({super.key});

  @override
  State<ReproductionFormScreen> createState() =>
      _ReproductionFormScreenState();
}

class _ReproductionFormScreenState extends State<ReproductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nbPetitsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  TypeReproduction _type = TypeReproduction.saillie;
  Animal? _femelle;
  Animal? _male;
  DateTime _date = DateTime.now();
  DateTime? _dateAttendue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AnimalProvider>().chargerAnimaux());
  }

  @override
  void dispose() {
    _nbPetitsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate() || _femelle == null) return;
    final r = Reproduction(
      id: const Uuid().v4(),
      femelleId: _femelle!.id,
      maleId: _male?.id,
      type: _type,
      date: _date,
      dateAttendue: _dateAttendue,
      nbPetits: int.tryParse(_nbPetitsCtrl.text),
      notes:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      creeLe: DateTime.now(),
    );
    await context.read<ReproductionProvider>().ajouter(r);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle entrée reproduction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<TypeReproduction>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: TypeReproduction.values
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            Consumer<AnimalProvider>(
              builder: (_, ap, __) {
                final femelles = ap.animaux
                    .where((a) => a.sexe == SexeAnimal.femelle)
                    .toList();
                final males = ap.animaux
                    .where((a) => a.sexe == SexeAnimal.male)
                    .toList();
                return Column(
                  children: [
                    DropdownButtonFormField<Animal>(
                      value: _femelle,
                      decoration:
                          const InputDecoration(labelText: 'Femelle *'),
                      items: femelles
                          .map((a) => DropdownMenuItem(
                              value: a,
                              child: Text('${a.nom} (${a.identifiant})')))
                          .toList(),
                      onChanged: (v) => setState(() => _femelle = v),
                      validator: (v) =>
                          v == null ? 'Sélectionner une femelle' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Animal>(
                      value: _male,
                      decoration: const InputDecoration(
                          labelText: 'Mâle (optionnel)'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Aucun')),
                        ...males.map((a) => DropdownMenuItem(
                            value: a,
                            child: Text('${a.nom} (${a.identifiant})')))
                      ],
                      onChanged: (v) => setState(() => _male = v),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final r = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365)),
                  locale: const Locale('fr', 'FR'),
                );
                if (r != null) setState(() => _date = r);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(dateFmt.format(_date)),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final r = await showDatePicker(
                  context: context,
                  initialDate: _dateAttendue ??
                      DateTime.now().add(const Duration(days: 280)),
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365)),
                  locale: const Locale('fr', 'FR'),
                );
                if (r != null) setState(() => _dateAttendue = r);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Mise bas attendue (optionnel)'),
                child: Text(_dateAttendue != null
                    ? dateFmt.format(_dateAttendue!)
                    : 'Choisir une date'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nbPetitsCtrl,
              decoration: const InputDecoration(
                  labelText: 'Nombre de petits (si mise bas)'),
              keyboardType: TextInputType.number,
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
