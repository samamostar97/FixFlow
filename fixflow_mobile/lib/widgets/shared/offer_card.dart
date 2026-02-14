import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OfferCard extends StatelessWidget {
  final OfferResponse offer;
  final VoidCallback? onAccept;
  final VoidCallback? onWithdraw;

  const OfferCard({
    super.key,
    required this.offer,
    this.onAccept,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MobileSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 10),
            _buildDetails(theme),
            if (offer.note != null && offer.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                offer.note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (onAccept != null || onWithdraw != null) ...[
              const SizedBox(height: 12),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            offer.technicianFullName,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _OfferStatusBadge(status: offer.status),
      ],
    );
  }

  Widget _buildDetails(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _detailChip(
          theme,
          LucideIcons.wallet,
          CurrencyFormatter.format(offer.price),
        ),
        _detailChip(theme, LucideIcons.clock3, '${offer.estimatedDays} dana'),
        _detailChip(theme, LucideIcons.wrench, offer.serviceType.displayName),
      ],
    );
  }

  Widget _detailChip(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onWithdraw != null)
          TextButton(onPressed: onWithdraw, child: const Text('Povuci')),
        if (onAccept != null)
          FilledButton(onPressed: onAccept, child: const Text('Prihvati')),
      ],
    );
  }
}

class _OfferStatusBadge extends StatelessWidget {
  final OfferStatus status;

  const _OfferStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OfferStatus.pending => AppStatusColors.pending,
      OfferStatus.accepted => AppStatusColors.completed,
      OfferStatus.rejected => AppStatusColors.cancelled,
      OfferStatus.withdrawn => Theme.of(context).colorScheme.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
