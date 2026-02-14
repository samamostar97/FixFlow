import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/widgets/shared/job_status_badge.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';

class BookingHeaderCard extends StatelessWidget {
  final BookingResponse booking;

  const BookingHeaderCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.repairRequestCategoryName,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatWithTime(booking.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          JobStatusBadge(status: booking.jobStatus),
        ],
      ),
    );
  }
}

class BookingPersonInfoCard extends StatelessWidget {
  final String title;
  final String fullName;
  final String? phone;
  final String serviceType;
  final DateTime? scheduledDate;
  final String scheduledLabel;

  const BookingPersonInfoCard({
    super.key,
    required this.title,
    required this.fullName,
    required this.phone,
    required this.serviceType,
    required this.scheduledDate,
    this.scheduledLabel = 'Zakazano',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _InfoRow(label: 'Ime', value: fullName),
          if (phone != null) _InfoRow(label: 'Telefon', value: phone!),
          _InfoRow(label: 'Tip usluge', value: serviceType),
          if (scheduledDate != null)
            _InfoRow(
              label: scheduledLabel,
              value: DateFormatter.format(scheduledDate!),
            ),
        ],
      ),
    );
  }
}

class BookingRequestInfoCard extends StatelessWidget {
  final String description;

  const BookingRequestInfoCard({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opis zahtjeva', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    );
  }
}

class BookingPartsInfoCard extends StatelessWidget {
  final String partsDescription;
  final double? partsCost;

  const BookingPartsInfoCard({
    super.key,
    required this.partsDescription,
    required this.partsCost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dijelovi', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(partsDescription),
          const SizedBox(height: 4),
          Text(
            'Cijena: ${CurrencyFormatter.format(partsCost ?? 0)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingPriceBreakdownCard extends StatelessWidget {
  final double offerPrice;
  final double? partsCost;
  final double totalAmount;

  const BookingPriceBreakdownCard({
    super.key,
    required this.offerPrice,
    required this.partsCost,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cijena', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Ponuda',
            value: CurrencyFormatter.format(offerPrice),
          ),
          if (partsCost != null)
            _PriceRow(
              label: 'Dijelovi',
              value: CurrencyFormatter.format(partsCost!),
            ),
          const Divider(height: 16),
          _PriceRow(
            label: 'Ukupno',
            value: CurrencyFormatter.format(totalAmount),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
