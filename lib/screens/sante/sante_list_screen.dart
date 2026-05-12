import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/sante_provider.dart';
import '../../widgets/empty_state.dart';
import 'sante_form_screen.dart';

class SanteListScreen extends StatefulWidget {
  const SanteListScreen({super.key});

  @override
  State<SanteListScreen> createState() => _SanteListScreenState();
}

class _SanteListScreenState extends State<SanteListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SanteProvider>().charger());
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    return Scaffold(
      appBar: AppBar(title: const Text('Santé & Vaccinations')),
      body: Consumer<SanteProvider>(
        builder: (_, sp, __) {
          if (sp.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sp.entrees.isEmpty) {
            return EmptyState(
              icone: Icons.medical_services,
              titre: 'Aucun enregistrement',
              sousTitre: 'Ajoutez vaccinations, traitements et consultations.',
              actionLabel: 'Ajouter',
              onAction: () => _ouvrir(context),
            );
          }
          return RefreshIndicator(
            onRefresh: () => sp.charger(),
            child: ListView.separated(
              itemCount: sp.entrees.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final s = sp.entrees[i];
                return ListTile(
                  leading: const CircleAvatar(
                      child: Icon(Icons.medical_services)),
                  title: Text(s.libelle),
                  subtitle: Text(
                      '${s.type.label} · ${dateFmt.format(s.date)}${s.veterinaire != null ? ' · ${s.veterinaire}' : ''}'),
                  trailing: s.prochainRappel != null
                      ? Tooltip(
                          message: 'Rappel: ${dateFmt.format(s.prochainRappel!)}',
                          child: const Icon(Icons.notifications_active,
                              color: Colors.orange),
                        )
                      : null,
                  onLongPress: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Supprimer cet enregistrement ?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Annuler')),
                          FilledButton.tonal(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Supprimer')),
                        ],
                      ),
                    );
                    if (ok == true) sp.supprimer(s.id);
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SanteFormScreen()));
  }
}
