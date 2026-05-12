import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/animal.dart';
import '../../models/transaction.dart' as model;
import '../../providers/animal_provider.dart';
import '../../providers/finance_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  model.TypeTransaction _type = model.TypeTransaction.depense;
  model.CategorieTransaction _categorie =
      model.CategorieTransaction.alimentation;
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
    _montantCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    final t = model.Transaction(
      id: const Uuid().v4(),
      type: _type,
      categorie: _categorie,
      montant: double.parse(_montantCtrl.text.replaceAll(',', '.')),
      date: _date,
      animalId: _animal?.id,
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      creeLe: DateTime.now(),
    );
    await context.read<FinanceProvider>().ajouter(t);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<model.TypeTransaction>(
              segments: const [
                ButtonSegment(
                    value: model.TypeTransaction.revenu,
                    label: Text('Revenu'),
                    icon: Icon(Icons.arrow_upward)),
                ButtonSegment(
                    value: model.TypeTransaction.depense,
                    label: Text('Dépense'),
                    icon: Icon(Icons.arrow_downward)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<model.CategorieTransaction>(
              value: _categorie,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: model.CategorieTransaction.values
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (v) => setState(() => _categorie = v ?? _categorie),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _montantCtrl,
              decoration: const InputDecoration(labelText: 'Montant *'),
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
            Consumer<AnimalProvider>(
              builder: (_, ap, __) => DropdownButtonFormField<Animal?>(
                value: _animal,
                decoration: const InputDecoration(
                    labelText: 'Animal lié (optionnel)'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Aucun')),
                  ...ap.animaux.map((a) => DropdownMenuItem(
                      value: a,
                      child: Text('${a.nom} (${a.identifiant})')))
                ],
                onChanged: (v) => setState(() => _animal = v),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
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
