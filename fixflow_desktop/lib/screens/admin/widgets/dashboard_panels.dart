import 'package:fixflow_desktop/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardChartPanel extends StatelessWidget {
  const DashboardChartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            title: 'Statistika zahtjeva',
            subtitle: 'Mjesecni trendovi po statusima (placeholder podaci).',
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(child: _ChartPlaceholder()),
        ],
      ),
    );
  }
}

class DashboardActivityPanel extends StatelessWidget {
  const DashboardActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DashboardPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nedavna aktivnost', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView.separated(
              itemCount: _activityItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                return _ActivityTimelineTile(item: _activityItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPanelShell extends StatelessWidget {
  final Widget child;

  const _DashboardPanelShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PanelTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
        color: cs.surfaceContainerLow.withValues(alpha: 0.35),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.areaChart, size: 40, color: cs.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Grafikon dolazi uskoro',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'OPEN 42  |  IN_PROGRESS 31  |  COMPLETED 55',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTimelineTile extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityTimelineTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 14, color: item.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  item.detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.time,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final String title;
  final String detail;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.detail,
    required this.time,
    required this.icon,
    required this.color,
  });
}

const _activityItems = <_ActivityItem>[
  _ActivityItem(
    title: 'Novi zahtjev je kreiran',
    detail: 'Kategorija Laptop, lokacija Centar.',
    time: 'prije 5m',
    icon: LucideIcons.filePlus,
    color: Color(0xFF22D3EE),
  ),
  _ActivityItem(
    title: 'Ponuda je prihvacena',
    detail: 'Zahtjev #221 je presao u booking.',
    time: 'prije 18m',
    icon: LucideIcons.badgeCheck,
    color: Color(0xFF10B981),
  ),
  _ActivityItem(
    title: 'Majstor je verificiran',
    detail: 'Profil Adnan H. je uspjesno potvrden.',
    time: 'prije 33m',
    icon: LucideIcons.shieldCheck,
    color: Color(0xFFA78BFA),
  ),
  _ActivityItem(
    title: 'Oznacen prioritetan kvar',
    detail: 'Zahtjev #219 ima hitni servis.',
    time: 'prije 1h',
    icon: LucideIcons.alertTriangle,
    color: Color(0xFFF59E0B),
  ),
];
