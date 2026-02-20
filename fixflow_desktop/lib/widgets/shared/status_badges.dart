import 'package:fixflow_core/fixflow_core.dart';
import 'package:flutter/material.dart';

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

    return _StatusPill(label: status.displayName, color: color);
  }
}

class OfferStatusBadge extends StatelessWidget {
  final OfferStatus status;

  const OfferStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OfferStatus.pending => AppStatusColors.pending,
      OfferStatus.accepted => AppStatusColors.completed,
      OfferStatus.rejected => AppStatusColors.cancelled,
      OfferStatus.withdrawn => Theme.of(context).colorScheme.onSurfaceVariant,
    };

    return _StatusPill(label: status.displayName, color: color);
  }
}

class JobStatusBadge extends StatelessWidget {
  final JobStatus status;

  const JobStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      JobStatus.received => AppStatusColors.pending,
      JobStatus.diagnostics => AppStatusColors.inProgress,
      JobStatus.waitingForPart => AppStatusColors.open,
      JobStatus.repaired => AppStatusColors.completed,
      JobStatus.completed => AppStatusColors.completed,
    };

    return _StatusPill(label: status.displayName, color: color);
  }
}

class PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const PaymentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PaymentStatus.pending => AppStatusColors.pending,
      PaymentStatus.completed => AppStatusColors.completed,
      PaymentStatus.failed => AppStatusColors.cancelled,
      PaymentStatus.refunded => AppStatusColors.open,
    };

    return _StatusPill(label: status.displayName, color: color);
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
