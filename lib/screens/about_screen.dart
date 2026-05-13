import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('A propos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.15),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  '🐄',
                  style: TextStyle(fontSize: 72),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'HOGO',
              style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 3,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              "Application de gestion d'elevage",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developpeur',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Divider(),
                  const _InfoRow(
                    icone: Icons.person,
                    label: 'Nom',
                    valeur: 'DIKO Soule',
                  ),
                  const _InfoRow(
                    icone: Icons.business,
                    label: 'Societe',
                    valeur: 'DSSI\nDigital System and Sciences IT',
                  ),
                  const _InfoRow(
                    icone: Icons.workspace_premium,
                    label: 'Fonction',
                    valeur: 'PDG',
                  ),
                  const _InfoRow(
                    icone: Icons.phone,
                    label: 'Telephone',
                    valeur: '+226 61 28 29 14',
                  ),
                  const _InfoRow(
                    icone: Icons.phone_android,
                    label: 'Mobile',
                    valeur: '+226 64 31 18 06',
                  ),
                  const _InfoRow(
                    icone: Icons.email,
                    label: 'Email',
                    valeur: 'diko.souley9378@gmail.com',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "A propos de l'application",
                    style: theme.textTheme.titleMedium,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    "HOGO est une application mobile de gestion d'elevage. "
                    "Suivi des animaux (bovins, ovins, caprins, volailles, etc.), "
                    "gestion sanitaire, reproduction, production et finances. "
                    "Fonctionne entierement hors ligne.",
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Copyright 2026 DSSI - Tous droits reserves',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valeur;

  const _InfoRow({
    required this.icone,
    required this.label,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(valeur)),
        ],
      ),
    );
  }
}

