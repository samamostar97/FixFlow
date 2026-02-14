import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MobileKpiItem {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color accent;

  const MobileKpiItem({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.accent,
  });
}

class MobileDashboardKpiStrip extends StatelessWidget {
  final List<MobileKpiItem> items;

  const MobileDashboardKpiStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                MobileDashboardKpiCard(item: items[i]),
                if (i < items.length - 1) const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        }

        final cardWidth = (constraints.maxWidth - AppSpacing.sm) / 2;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: items.map((item) {
            return SizedBox(
              width: cardWidth,
              child: MobileDashboardKpiCard(item: item),
            );
          }).toList(),
        );
      },
    );
  }
}

class MobileDashboardKpiCard extends StatelessWidget {
  final MobileKpiItem item;

  const MobileDashboardKpiCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MobileSectionCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [_buildKpiIcon(), const Spacer(), _buildTrendBadge(context)],
    );
  }

  Widget _buildKpiIcon() {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: item.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(item.icon, size: 14, color: item.accent),
    );
  }

  Widget _buildTrendBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: item.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        item.trend,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: item.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MobileActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const MobileActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class MobileDashboardActivityPanel extends StatelessWidget {
  final String title;
  final List<MobileActivityItem> items;
  final String emptyText;

  const MobileDashboardActivityPanel({
    super.key,
    required this.title,
    required this.items,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        MobileSectionCard(
          child: items.isEmpty
              ? _buildEmpty(context, cs)
              : Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      _ActivityRow(item: items[i]),
                      if (i < items.length - 1)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(LucideIcons.info, color: cs.onSurfaceVariant, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              emptyText,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final MobileActivityItem item;

  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 14, color: item.color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            item.time,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
