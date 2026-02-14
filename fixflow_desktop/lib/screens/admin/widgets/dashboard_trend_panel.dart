import 'package:fixflow_desktop/constants/app_spacing.dart';
import 'package:fixflow_desktop/screens/admin/widgets/dashboard_panel_shell.dart';
import 'package:flutter/material.dart';

class DashboardTrendPanel extends StatelessWidget {
  const DashboardTrendPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardPanelTitle(
            title: 'Statistika zahtjeva',
            subtitle: 'Sedmicni presjek po statusima (placeholder podaci).',
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(child: _TrendBars()),
        ],
      ),
    );
  }
}

class _TrendBars extends StatelessWidget {
  const _TrendBars();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
        color: cs.surfaceContainerLow.withValues(alpha: 0.35),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _trendItems.length; i++) ...[
            Expanded(child: _TrendBar(item: _trendItems[i])),
            if (i < _trendItems.length - 1)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  final _TrendItem item;

  const _TrendBar({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: item.heightFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          item.label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text('${item.value}', style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _TrendItem {
  final String label;
  final int value;
  final double heightFactor;
  final Color color;

  const _TrendItem({
    required this.label,
    required this.value,
    required this.heightFactor,
    required this.color,
  });
}

const _trendItems = <_TrendItem>[
  _TrendItem(
    label: 'OPEN',
    value: 42,
    heightFactor: 0.66,
    color: Color(0xFF22D3EE),
  ),
  _TrendItem(
    label: 'OFFERED',
    value: 31,
    heightFactor: 0.48,
    color: Color(0xFFA78BFA),
  ),
  _TrendItem(
    label: 'IN_PROGRESS',
    value: 27,
    heightFactor: 0.42,
    color: Color(0xFFF59E0B),
  ),
  _TrendItem(
    label: 'COMPLETED',
    value: 55,
    heightFactor: 0.86,
    color: Color(0xFF10B981),
  ),
];
