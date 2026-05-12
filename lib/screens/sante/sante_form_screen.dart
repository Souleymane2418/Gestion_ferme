import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/animal.dart';
import '../../models/sante.dart';
import '../../providers/animal_provider.dart';
import '../../providers/sante_provider.dart';

class SanteFormScreen extends StatefulWidget {
  const SanteFormScreen({super.key});

  @override
  State<SanteFormScreen> createState() => _SanteFormScreenState();
}

class _SanteFormScreenState extends State<SanteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _libelleCtrl = TextEditingController();
  final _veterinaireCtrl = TextEditingController();
  final _coutCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  TypeSante _type = TypeSante.vaccination;
  Animal? _animal;
  DateTime _date = DateTime.now();
  DateTime? _prochainRappel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AnimalProvider>().chargerAnimaux());
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _veterinaireCtrl.dispose();
    _coutCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate() || _animal == null) return;
    final s = Sante(
      id: const Uuid().v4(),
      animalId: _animal!.id,
      type: _type,
      libelle: _libelleCtrl.text.trim(),
      date: _date,
      prochainRappel: _prochainRappel,
      veterinaire: _veterinaireCtrl.text.trim().isEmpty
          ? null
          : _veterinaireCtrl.text.trim(),
      cout: double.tryParse(_coutCtrl.text.replaceAll(',', '.')),
      notes:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      creeLe: DateTime.now(),
    );
    await context.read<SanteProvider>().ajouter(s);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau soin / vaccin')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Consumer<AnimalProvider>(
              builder: (_, ap, __) => DropdownButtonFormField<Animal>(
                value: _animal,
                decoration: const InputDecoration(labelText: 'Animal *'),
                items: ap.animaux
                    .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text('${a.nom} (${a.identifiant})')))
                    .toList(),
                onChanged: (v) => setState(() => _animal = v),
                validator: (v) =>
                    v == null ? 'Sélectionner un animal' : null,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TypeSante>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: TypeSante.values
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _libelleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Libellé *',
                  hintText: 'Ex: Vaccin Foot & Mouth'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final r = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
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
                  initialDate: _prochainRappel ??
                      DateTime.now().add(const Duration(days: 180)),
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365 * 5)),
                  locale: const Locale('fr', 'FR'),
                );
                if (r != null) setState(() => _prochainRappel = r);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Prochain rappel (optionnel)'),
                child: Text(_prochainRappel != null
                    ? dateFmt.format(_prochainRappel!)
                    : 'Choisir une date'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _veterinaireCtrl,
              decoration: const InputDecoration(labelText: 'Vétérinaire'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _coutCtrl,
              decoration: const InputDecoration(labelText: 'Coût'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
