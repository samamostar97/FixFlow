import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StarRatingInput extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;
  final String? errorText;

  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ocjena',
          style: theme.textTheme.labelLarge?.copyWith(
            color: hasError
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isFilled = value != null && starValue <= value!;

            return IconButton(
              iconSize: 32,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
              onPressed: () => onChanged(starValue),
              icon: Icon(
                isFilled ? LucideIcons.star : LucideIcons.star,
                color: isFilled
                    ? Colors.amber
                    : theme.colorScheme.outlineVariant,
              ),
            );
          }),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class StarRatingDisplay extends StatelessWidget {
  final int rating;
  final double size;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          LucideIcons.star,
          size: size,
          color:
              index < rating ? Colors.amber : theme.colorScheme.outlineVariant,
        );
      }),
    );
  }
}
