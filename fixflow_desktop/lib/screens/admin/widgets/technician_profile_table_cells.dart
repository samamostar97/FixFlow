import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TechnicianVerificationBadge extends StatelessWidget {
  final bool isVerified;

  const TechnicianVerificationBadge({super.key, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tone = isVerified ? cs.tertiary : cs.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
      ),
      child: Text(
        isVerified ? 'Verificiran' : 'Ceka verifikaciju',
        style: TextStyle(
          color: tone,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class TechnicianVerificationAction extends StatelessWidget {
  final bool isVerified;
  final VoidCallback onVerify;

  const TechnicianVerificationAction({
    super.key,
    required this.isVerified,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.badgeCheck,
            size: 15,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 6),
          const Text('Aktivan'),
        ],
      );
    }

    return SizedBox(
      height: 32,
      child: FilledButton.tonalIcon(
        onPressed: onVerify,
        icon: const Icon(LucideIcons.shieldCheck, size: 14),
        label: const Text('Verificiraj'),
      ),
    );
  }
}
