import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'animaux/animaux_list_screen.dart';
import 'sante/sante_list_screen.dart';
import 'reproduction/reproduction_list_screen.dart';
import 'production/production_list_screen.dart';
import 'finance/finance_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    AnimauxListScreen(),
    SanteListScreen(),
    ReproductionListScreen(),
    ProductionListScreen(),
    FinanceScreen(),
  ];

  final _items = const [
    NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Accueil'),
    NavigationDestination(
        icon: Icon(Icons.pets_outlined),
        selectedIcon: Icon(Icons.pets),
        label: 'Animaux'),
    NavigationDestination(
        icon: Icon(Icons.medical_services_outlined),
        selectedIcon: Icon(Icons.medical_services),
        label: 'Santé'),
    NavigationDestination(
        icon: Icon(Icons.favorite_outline),
        selectedIcon: Icon(Icons.favorite),
        label: 'Repro'),
    NavigationDestination(
        icon: Icon(Icons.egg_outlined),
        selectedIcon: Icon(Icons.egg),
        label: 'Production'),
    NavigationDestination(
        icon: Icon(Icons.attach_money_outlined),
        selectedIcon: Icon(Icons.attach_money),
        label: 'Finances'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _items,
      ),
    );
  }
}
