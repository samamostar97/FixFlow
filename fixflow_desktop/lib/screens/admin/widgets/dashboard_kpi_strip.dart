import 'package:fixflow_desktop/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardKpiStrip extends StatelessWidget {
  final double width;

  const DashboardKpiStrip({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    if (width >= 1200) {
      return _buildWideRow(context);
    }

    if (width >= 700) {
      return _buildTwoColumnWrap(context);
    }

    return _buildColumn(context);
  }

  Widget _buildWideRow(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _kpiItems.length; i++) ...[
          Expanded(child: _KpiCard(item: _kpiItems[i])),
          if (i < _kpiItems.length - 1) const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _buildTwoColumnWrap(BuildContext context) {
    final cardWidth = (width - AppSpacing.md) / 2;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: _kpiItems
          .map(
            (item) => SizedBox(
              width: cardWidth,
              child: _KpiCard(item: item),
            ),
          )
          .toList(),
    );
  }

  Widget _buildColumn(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _kpiItems.length; i++) ...[
          _KpiCard(item: _kpiItems[i]),
          if (i < _kpiItems.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiItem item;

  const _KpiCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, cs),
          const SizedBox(height: AppSpacing.sm),
          _buildValue(context),
          const SizedBox(height: AppSpacing.xs),
          _buildMeta(context, cs),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Row(
      children: [
        _KpiIcon(icon: item.icon, color: item.accent),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _KpiTrendChip(value: item.trend, color: item.accent),
      ],
    );
  }

  Widget _buildValue(BuildContext context) {
    return Text(
      item.value,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildMeta(BuildContext context, ColorScheme cs) {
    return Text(
      item.meta,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
    );
  }
}

class _KpiIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _KpiIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _KpiTrendChip extends StatelessWidget {
  final String value;
  final Color color;

  const _KpiTrendChip({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _KpiItem {
  final String label;
  final String value;
  final String trend;
  final String meta;
  final IconData icon;
  final Color accent;

  const _KpiItem({
    required this.label,
    required this.value,
    required this.trend,
    required this.meta,
    required this.icon,
    required this.accent,
  });
}

const _kpiItems = <_KpiItem>[
  _KpiItem(
    label: 'Aktivni zahtjevi',
    value: '128',
    trend: '+12%',
    meta: 'u odnosu na proslu sedmicu',
    icon: LucideIcons.wrench,
    accent: Color(0xFF22D3EE),
  ),
  _KpiItem(
    label: 'Aktivni majstori',
    value: '42',
    trend: '+8%',
    meta: 'trenutno online i dostupni',
    icon: LucideIcons.users,
    accent: Color(0xFF10B981),
  ),
  _KpiItem(
    label: 'Zavrsene popravke',
    value: '96',
    trend: '+15%',
    meta: 'uspjesno zatvoreni poslovi',
    icon: LucideIcons.checkCircle,
    accent: Color(0xFFA78BFA),
  ),
  _KpiItem(
    label: 'Ukupan prihod',
    value: 'KM 24.3K',
    trend: '+9%',
    meta: 'obracun za ovaj mjesec',
    icon: LucideIcons.wallet,
    accent: Color(0xFFF59E0B),
  ),
];
