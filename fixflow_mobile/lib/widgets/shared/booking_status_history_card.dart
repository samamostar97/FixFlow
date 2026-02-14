import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';

class BookingStatusHistoryCard extends StatelessWidget {
  final List<JobStatusHistoryResponse> history;

  const BookingStatusHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final sorted = List<JobStatusHistoryResponse>.from(history)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final theme = Theme.of(context);

    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Historija statusa', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          if (sorted.isEmpty)
            const Text('Nema historije.')
          else
            ...sorted.map((entry) => _StatusHistoryItem(entry: entry)),
        ],
      ),
    );
  }
}

class _StatusHistoryItem extends StatelessWidget {
  final JobStatusHistoryResponse entry;

  const _StatusHistoryItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.newStatus.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.note != null && entry.note!.isNotEmpty)
                  Text(
                    entry.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  '${DateFormatter.formatWithTime(entry.createdAt)} - ${entry.changedByFullName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
