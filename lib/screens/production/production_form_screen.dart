import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/animal.dart';
import '../../models/production.dart';
import '../../providers/animal_provider.dart';
import '../../providers/production_provider.dart';

class ProductionFormScreen extends StatefulWidget {
  const ProductionFormScreen({super.key});

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  TypeProduction _type = TypeProduction.lait;
  Animal? _animal;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AnimalProvider>().chargerAnimaux());
  }

  @override
  void dispose() {
    _quantiteCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final p = Production(
      id: const Uuid().v4(),
      animalId: _animal?.id,
      type: _type,
      quantite: double.parse(_quantiteCtrl.text.replaceAll(',', '.')),
      date: _date,
      notes:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      creeLe: DateTime.now(),
    );
    await context.read<ProductionProvider>().ajouter(p);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle production')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<TypeProduction>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: TypeProduction.values
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantiteCtrl,
              decoration: InputDecoration(
                  labelText: 'Quantité (${_type.unite}) *'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requis';
                if (double.tryParse(v.replaceAll(',', '.')) == null) {
                  return 'Nombre invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Consumer<AnimalProvider>(
              builder: (_, ap, __) => DropdownButtonFormField<Animal?>(
                value: _animal,
                decoration: const InputDecoration(
                    labelText: 'Animal (optionnel - sinon collectif)'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Production collective')),
                  ...ap.animaux.map((a) => DropdownMenuItem(
                      value: a,
                      child: Text('${a.nom} (${a.identifiant})')))
                ],
                onChanged: (v) => setState(() => _animal = v),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final r = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
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
