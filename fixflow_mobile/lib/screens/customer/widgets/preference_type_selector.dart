import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PreferenceTypeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PreferenceTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 380) {
          return _buildCompactChips(context);
        }

        return _buildSegmented(context);
      },
    );
  }

  Widget _buildSegmented(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tip usluge *', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              label: Text('Na licu mjesta'),
              icon: Icon(LucideIcons.home),
            ),
            ButtonSegment(
              value: 1,
              label: Text('Donijeti u servis'),
              icon: Icon(LucideIcons.store),
            ),
          ],
          selected: {value},
          onSelectionChanged: (values) => onChanged(values.first),
        ),
      ],
    );
  }

  Widget _buildCompactChips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tip usluge *', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              selected: value == 0,
              onSelected: (selected) {
                if (selected) {
                  onChanged(0);
                }
              },
              avatar: const Icon(LucideIcons.home, size: 16),
              label: const Text('Na licu mjesta'),
            ),
            ChoiceChip(
              selected: value == 1,
              onSelected: (selected) {
                if (selected) {
                  onChanged(1);
                }
              },
              avatar: const Icon(LucideIcons.store, size: 16),
              label: const Text('Donijeti u servis'),
            ),
          ],
        ),
      ],
    );
  }
}
