import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../providers/animal_provider.dart';
import '../../widgets/empty_state.dart';
import 'animal_detail_screen.dart';
import 'animal_form_screen.dart';

class AnimauxListScreen extends StatefulWidget {
  const AnimauxListScreen({super.key});

  @override
  State<AnimauxListScreen> createState() => _AnimauxListScreenState();
}

class _AnimauxListScreenState extends State<AnimauxListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AnimalProvider>().chargerAnimaux());
  }

  IconData _iconePourEspece(EspeceAnimal e) {
    switch (e) {
      case EspeceAnimal.bovin:
        return Icons.agriculture;
      case EspeceAnimal.volaille:
        return Icons.egg;
      case EspeceAnimal.ovin:
      case EspeceAnimal.caprin:
        return Icons.cruelty_free;
      case EspeceAnimal.porcin:
        return Icons.savings;
      case EspeceAnimal.equin:
        return Icons.directions_run;
      case EspeceAnimal.autre:
        return Icons.pets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animaux'),
        actions: [
          Consumer<AnimalProvider>(
            builder: (_, ap, __) => PopupMenuButton<EspeceAnimal?>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtrer',
              onSelected: ap.definirFiltreEspece,
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('Toutes')),
                ...EspeceAnimal.values.map(
                  (e) => PopupMenuItem(value: e, child: Text(e.label)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<AnimalProvider>(
        builder: (_, ap, __) {
          if (ap.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ap.animaux.isEmpty) {
            return EmptyState(
              icone: Icons.pets,
              titre: 'Aucun animal',
              sousTitre: 'Commencez par ajouter votre premier animal.',
              actionLabel: 'Ajouter un animal',
              onAction: () => _ouvrirFormulaire(context),
            );
          }
          return RefreshIndicator(
            onRefresh: ap.chargerAnimaux,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: ap.animaux.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final a = ap.animaux[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(_iconePourEspece(a.espece)),
                  ),
                  title: Text('${a.nom} (${a.identifiant})'),
                  subtitle: Text(
                      '${a.espece.label} · ${a.sexe.label}${a.race != null ? ' · ${a.race}' : ''}'),
                  trailing: Chip(
                    label: Text(a.statut.label,
                        style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AnimalDetailScreen(animalId: a.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ouvrirFormulaire(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  void _ouvrirFormulaire(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AnimalFormScreen()),
    );
  }
}
