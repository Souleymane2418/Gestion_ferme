import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../providers/animal_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/sante_provider.dart';
import '../providers/reproduction_provider.dart';
import '../widgets/stat_card.dart';
import 'about_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  Future<void> _charger() async {
    await Future.wait([
      context.read<AnimalProvider>().chargerAnimaux(),
      context.read<SanteProvider>().charger(),
      context.read<ReproductionProvider>().charger(),
      context.read<FinanceProvider>().charger(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'F');
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐄', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text('HOGO',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _charger,
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraichir',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            icon: const Icon(Icons.info_outline),
            tooltip: 'A propos',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Vue d'ensemble",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Consumer<AnimalProvider>(
              builder: (_, ap, __) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    titre: 'Animaux actifs',
                    valeur: ap.nbActifs.toString(),
                    icone: Icons.pets,
                  ),
                  Consumer<FinanceProvider>(
                    builder: (_, fp, __) => StatCard(
                      titre: 'Benefice',
                      valeur: fmt.format(fp.benefice),
                      icone: Icons.trending_up,
                      couleur: fp.benefice >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  Consumer<FinanceProvider>(
                    builder: (_, fp, __) => StatCard(
                      titre: 'Revenus',
                      valeur: fmt.format(fp.totalRevenus),
                      icone: Icons.arrow_upward,
                      couleur: Colors.green,
                    ),
                  ),
                  Consumer<FinanceProvider>(
                    builder: (_, fp, __) => StatCard(
                      titre: 'Depenses',
                      valeur: fmt.format(fp.totalDepenses),
                      icone: Icons.arrow_downward,
                      couleur: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Repartition par espece',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            FutureBuilder<Map<EspeceAnimal, int>>(
              future: context.read<AnimalProvider>().repartitionParEspece(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                final data = snap.data!;
                if (data.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aucun animal enregistre pour le moment.'),
                    ),
                  );
                }
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: data.entries
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 10),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(e.key.label)),
                                    Text(e.value.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Rappels a venir (30 j)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Consumer<SanteProvider>(builder: (_, sp, __) {
              if (sp.rappels.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Aucun rappel sanitaire a venir'),
                  ),
                );
              }
              return Card(
                child: Column(
                  children: sp.rappels.take(5).map((s) {
                    return ListTile(
                      leading: const Icon(Icons.medical_services,
                          color: Colors.orange),
                      title: Text(s.libelle),
                      subtitle: Text(
                          'Rappel: ' + dateFmt.format(s.prochainRappel!)),
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: 12),
            Text('Mises bas attendues',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Consumer<ReproductionProvider>(builder: (_, rp, __) {
              if (rp.misesBasAVenir.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Aucune mise bas prevue dans les 30 jours'),
                  ),
                );
              }
              return Card(
                child: Column(
                  children: rp.misesBasAVenir.take(5).map((r) {
                    return ListTile(
                      leading: const Icon(Icons.favorite, color: Colors.pink),
                      title: Text(r.type.label),
                      subtitle:
                          Text('Prevu: ' + dateFmt.format(r.dateAttendue!)),
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

