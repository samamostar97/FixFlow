import 'package:flutter/material.dart';

class AdminListErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AdminListErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Pokusaj ponovo')),
        ],
      ),
    );
  }
}

class AdminListEmptyState extends StatelessWidget {
  final String text;
  final IconData? icon;

  const AdminListEmptyState({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (icon == null) {
      return Center(child: Text(text));
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
