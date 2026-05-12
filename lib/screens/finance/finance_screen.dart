import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/transaction.dart' as model;
import '../../providers/finance_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_card.dart';
import 'transaction_form_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<FinanceProvider>().charger());
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'F');
    final dateFmt = DateFormat('dd MMM yyyy', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Finances')),
      body: Consumer<FinanceProvider>(
        builder: (_, fp, __) {
          return RefreshIndicator(
            onRefresh: () => fp.charger(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                        titre: 'Revenus',
                        valeur: fmt.format(fp.totalRevenus),
                        icone: Icons.arrow_upward,
                        couleur: Colors.green),
                    StatCard(
                        titre: 'Dépenses',
                        valeur: fmt.format(fp.totalDepenses),
                        icone: Icons.arrow_downward,
                        couleur: Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(
                  titre: 'Bénéfice net',
                  valeur: fmt.format(fp.benefice),
                  icone: Icons.account_balance,
                  couleur: fp.benefice >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text('Transactions',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (fp.transactions.isEmpty)
                  EmptyState(
                    icone: Icons.attach_money,
                    titre: 'Aucune transaction',
                    sousTitre: 'Enregistrez vos revenus et dépenses.',
                    actionLabel: 'Ajouter',
                    onAction: () => _ouvrir(context),
                  )
                else
                  ...fp.transactions.map((t) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                t.type == model.TypeTransaction.revenu
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                            child: Icon(
                              t.type == model.TypeTransaction.revenu
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: t.type == model.TypeTransaction.revenu
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(
                              t.description ?? t.categorie.label),
                          subtitle: Text(
                              '${t.categorie.label} · ${dateFmt.format(t.date)}'),
                          trailing: Text(
                            '${t.type == model.TypeTransaction.revenu ? '+' : '-'}${fmt.format(t.montant)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: t.type == model.TypeTransaction.revenu
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          onLongPress: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Supprimer ?'),
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
                            if (ok == true) fp.supprimer(t.id);
                          },
                        ),
                      )),
                const SizedBox(height: 80),
              ],
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
        .push(MaterialPageRoute(builder: (_) => const TransactionFormScreen()));
  }
}
