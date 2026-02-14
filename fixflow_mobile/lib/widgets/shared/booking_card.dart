import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/widgets/shared/job_status_badge.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookingCard extends StatelessWidget {
  final BookingResponse booking;
  final VoidCallback onTap;
  final bool showCustomerName;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.showCustomerName = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: MobileSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 10),
              _buildDetails(theme),
              const SizedBox(height: 8),
              _buildCounterparty(theme),
              if (booking.partsDescription != null) ...[
                const SizedBox(height: 6),
                _buildPartsNote(theme),
              ],
              const SizedBox(height: 8),
              Text(
                DateFormatter.format(booking.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            booking.repairRequestCategoryName,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        JobStatusBadge(status: booking.jobStatus),
      ],
    );
  }

  Widget _buildDetails(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _detailChip(
          theme,
          LucideIcons.wallet,
          CurrencyFormatter.format(booking.totalAmount),
        ),
        _detailChip(
          theme,
          LucideIcons.wrench,
          booking.offerServiceType.displayName,
        ),
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

  Widget _buildCounterparty(ThemeData theme) {
    final name = showCustomerName
        ? booking.customerFullName
        : booking.technicianFullName;
    final label = showCustomerName ? 'Korisnik' : 'Majstor';

    return Text(
      '$label: $name',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPartsNote(ThemeData theme) {
    return Text(
      booking.partsDescription!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
