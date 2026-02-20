import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:fixflow_mobile/widgets/shared/star_rating_input.dart';
import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final ReviewResponse review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vasa ocjena', style: theme.textTheme.titleSmall),
              StarRatingDisplay(rating: review.rating),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            DateFormatter.format(review.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
