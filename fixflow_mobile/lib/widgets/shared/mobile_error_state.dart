import 'package:flutter/material.dart';

class MobileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const MobileErrorState({
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
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Pokusaj ponovo')),
        ],
      ),
    );
  }
}
