import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/reproduction_provider.dart';
import '../../widgets/empty_state.dart';
import 'reproduction_form_screen.dart';

class ReproductionListScreen extends StatefulWidget {
  const ReproductionListScreen({super.key});

  @override
  State<ReproductionListScreen> createState() =>
      _ReproductionListScreenState();
}

class _ReproductionListScreenState extends State<ReproductionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ReproductionProvider>().charger());
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    return Scaffold(
      appBar: AppBar(title: const Text('Reproduction & Naissances')),
      body: Consumer<ReproductionProvider>(
        builder: (_, rp, __) {
          if (rp.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (rp.entrees.isEmpty) {
            return EmptyState(
              icone: Icons.favorite,
              titre: 'Aucun enregistrement',
              sousTitre: 'Suivez saillies, gestations et mises bas.',
              actionLabel: 'Ajouter',
              onAction: () => _ouvrir(context),
            );
          }
          return RefreshIndicator(
            onRefresh: () => rp.charger(),
            child: ListView.separated(
              itemCount: rp.entrees.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = rp.entrees[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.favorite)),
                  title: Text(r.type.label),
                  subtitle: Text(
                      '${dateFmt.format(r.date)}${r.dateAttendue != null ? ' · prévu ${dateFmt.format(r.dateAttendue!)}' : ''}${r.nbPetits != null ? ' · ${r.nbPetits} petit(s)' : ''}'),
                  onLongPress: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Supprimer ?'),
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
                    if (ok == true) rp.supprimer(r.id);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrir(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  void _ouvrir(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReproductionFormScreen()),
    );
  }
}
