import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String? sousTitre;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icone,
    required this.titre,
    this.sousTitre,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(titre, style: theme.textTheme.titleMedium),
            if (sousTitre != null) ...[
              const SizedBox(height: 8),
              Text(
                sousTitre!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
