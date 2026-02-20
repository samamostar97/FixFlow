import 'package:fixflow_core/fixflow_core.dart';
import 'package:flutter/material.dart';

class PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const PaymentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PaymentStatus.pending => AppStatusColors.pending,
      PaymentStatus.completed => AppStatusColors.completed,
      PaymentStatus.failed => AppStatusColors.cancelled,
      PaymentStatus.refunded => const Color(0xFF8B5CF6),
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
