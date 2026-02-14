import 'package:fixflow_desktop/constants/app_spacing.dart';
import 'package:fixflow_desktop/screens/admin/widgets/dashboard_panel_shell.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardStatusBreakdownPanel extends StatelessWidget {
  const DashboardStatusBreakdownPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardPanelTitle(
            title: 'Zahtjevi po statusu',
            subtitle: 'Operativna raspodjela aktivnih zahtjeva.',
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(child: _StatusRows()),
        ],
      ),
    );
  }
}

class DashboardUrgentRequestsPanel extends StatelessWidget {
  const DashboardUrgentRequestsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardPanelTitle(
            title: 'Prioritetni slucajevi',
            subtitle: 'Top 5 zahtjeva koji traze brzu reakciju.',
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              itemCount: _urgentCases.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                return _UrgentCaseTile(item: _urgentCases[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRows extends StatelessWidget {
  const _StatusRows();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(right: 14),
      itemCount: _statusRows.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return _StatusRow(item: _statusRows[index]);
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  final _StatusRowItem item;

  const _StatusRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${item.count}',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: item.color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: item.progress,
            backgroundColor: cs.surfaceContainerLow.withValues(alpha: 0.6),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
          ),
        ),
      ],
    );
  }
}

class _UrgentCaseTile extends StatelessWidget {
  final _UrgentCase item;

  const _UrgentCaseTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.siren, size: 16, color: Color(0xFFEF4444)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${item.requestId} - ${item.category}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.location} - ${item.elapsed}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          FilledButton.tonal(onPressed: () {}, child: const Text('Detalji')),
        ],
      ),
    );
  }
}

class _StatusRowItem {
  final String label;
  final int count;
  final double progress;
  final Color color;

  const _StatusRowItem({
    required this.label,
    required this.count,
    required this.progress,
    required this.color,
  });
}

class _UrgentCase {
  final int requestId;
  final String category;
  final String location;
  final String elapsed;

  const _UrgentCase({
    required this.requestId,
    required this.category,
    required this.location,
    required this.elapsed,
  });
}

const _statusRows = <_StatusRowItem>[
  _StatusRowItem(
    label: 'Otvoreni',
    count: 42,
    progress: 0.58,
    color: Color(0xFF22D3EE),
  ),
  _StatusRowItem(
    label: 'Ponudjeno',
    count: 31,
    progress: 0.43,
    color: Color(0xFFA78BFA),
  ),
  _StatusRowItem(
    label: 'U toku',
    count: 27,
    progress: 0.38,
    color: Color(0xFFF59E0B),
  ),
  _StatusRowItem(
    label: 'Zavrseno',
    count: 55,
    progress: 0.76,
    color: Color(0xFF10B981),
  ),
];

const _urgentCases = <_UrgentCase>[
  _UrgentCase(
    requestId: 241,
    category: 'Laptop',
    location: 'Centar, Mostar',
    elapsed: 'Prije 19 min',
  ),
  _UrgentCase(
    requestId: 238,
    category: 'Klima uredjaj',
    location: 'Zalik, Mostar',
    elapsed: 'Prije 27 min',
  ),
  _UrgentCase(
    requestId: 234,
    category: 'Ves masina',
    location: 'Tekija, Mostar',
    elapsed: 'Prije 41 min',
  ),
  _UrgentCase(
    requestId: 231,
    category: 'Mobilni telefon',
    location: 'Carina, Mostar',
    elapsed: 'Prije 55 min',
  ),
  _UrgentCase(
    requestId: 229,
    category: 'Bicikl',
    location: 'Avenija, Mostar',
    elapsed: 'Prije 1h 11m',
  ),
];
