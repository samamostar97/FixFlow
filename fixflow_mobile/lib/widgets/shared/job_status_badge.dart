import 'package:fixflow_core/fixflow_core.dart';
import 'package:flutter/material.dart';

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
