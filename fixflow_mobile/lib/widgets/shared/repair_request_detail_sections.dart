import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/widgets/shared/loading_skeleton.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:fixflow_mobile/widgets/shared/offer_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RepairRequestHeaderCard extends StatelessWidget {
  final RepairRequestResponse request;

  const RepairRequestHeaderCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.categoryName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatWithTime(request.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          RepairRequestStatusBadge(status: request.status),
        ],
      ),
    );
  }
}

class RepairRequestInfoCard extends StatelessWidget {
  final RepairRequestResponse request;

  const RepairRequestInfoCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opis', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(request.description),
          const Divider(height: 24),
          _InfoRow(
            label: 'Tip usluge',
            value: request.preferenceType.displayName,
          ),
          if (request.address != null)
            _InfoRow(label: 'Adresa', value: request.address!),
        ],
      ),
    );
  }
}

class RepairRequestOffersCard extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<OfferResponse> offers;
  final bool canAccept;
  final ValueChanged<OfferResponse> onAccept;

  const RepairRequestOffersCard({
    super.key,
    required this.isLoading,
    required this.error,
    required this.offers,
    required this.canAccept,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ponude', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          if (isLoading)
            const AppListSkeleton(itemCount: 2, padding: EdgeInsets.zero)
          else if (error != null)
            Text(error!, style: TextStyle(color: theme.colorScheme.error))
          else if (offers.isEmpty)
            const Text('Nema ponuda za ovaj zahtjev.')
          else
            ...offers.map(
              (offer) => OfferCard(
                offer: offer,
                onAccept: canAccept && offer.status == OfferStatus.pending
                    ? () => onAccept(offer)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

class RepairRequestImagesCard extends StatelessWidget {
  final List<RequestImageResponse> images;
  final String baseUrl;

  const RepairRequestImagesCard({
    super.key,
    required this.images,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Slike (${images.length})', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final image = images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '$baseUrl${image.imagePath}',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 120,
                      height: 120,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(LucideIcons.imageOff),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RepairRequestStatusBadge extends StatelessWidget {
  final RepairRequestStatus status;

  const RepairRequestStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RepairRequestStatus.open => AppStatusColors.open,
      RepairRequestStatus.offered => AppStatusColors.pending,
      RepairRequestStatus.accepted => AppStatusColors.completed,
      RepairRequestStatus.inProgress => AppStatusColors.inProgress,
      RepairRequestStatus.completed => AppStatusColors.completed,
      RepairRequestStatus.cancelled => AppStatusColors.cancelled,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
