import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/production.dart';
import '../../providers/production_provider.dart';
import '../../widgets/empty_state.dart';
import 'production_form_screen.dart';

class ProductionListScreen extends StatefulWidget {
  const ProductionListScreen({super.key});

  @override
  State<ProductionListScreen> createState() => _ProductionListScreenState();
}

class _ProductionListScreenState extends State<ProductionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ProductionProvider>().charger());
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');
    final numFmt = NumberFormat('#,##0.##', 'fr_FR');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production'),
        actions: [
          Consumer<ProductionProvider>(
            builder: (_, pp, __) => PopupMenuButton<TypeProduction?>(
              icon: const Icon(Icons.filter_list),
              onSelected: pp.definirFiltreType,
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('Tous')),
                ...TypeProduction.values.map(
                  (t) => PopupMenuItem(value: t, child: Text(t.label)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<ProductionProvider>(
        builder: (_, pp, __) {
          if (pp.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (pp.entrees.isEmpty) {
            return EmptyState(
              icone: Icons.egg,
              titre: 'Aucune production',
              sousTitre: 'Ajoutez le lait, les œufs ou autres productions.',
              actionLabel: 'Ajouter',
              onAction: () => _ouvrir(context),
            );
          }
          return RefreshIndicator(
            onRefresh: () => pp.charger(),
            child: ListView.separated(
              itemCount: pp.entrees.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final p = pp.entrees[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.egg)),
                  title: Text(
                      '${numFmt.format(p.quantite)} ${p.type.unite} · ${p.type.label}'),
                  subtitle: Text(dateFmt.format(p.date)),
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
                    if (ok == true) pp.supprimer(p.id);
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
        .push(MaterialPageRoute(builder: (_) => const ProductionFormScreen()));
  }
}
