import 'package:fixflow_desktop/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SidebarBrand extends StatelessWidget {
  final bool compact;

  const SidebarBrand({super.key, required this.compact});

  @override
  Widget build(BuildContext context) {
    final logo = _buildLogo();
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Tooltip(message: 'FixFlow', child: logo),
      );
    }

    return _ExpandedSidebarBrand(logo: logo);
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0891B2), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(LucideIcons.wrench, color: Colors.white, size: 20),
    );
  }
}

class _ExpandedSidebarBrand extends StatelessWidget {
  final Widget logo;

  const _ExpandedSidebarBrand({required this.logo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          logo,
          const SizedBox(width: AppSpacing.sm + 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FixFlow',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Admin Dashboard',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.inverseSurface,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SidebarSectionHeader extends StatelessWidget {
  final String label;

  const SidebarSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF334155),
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontSize: 10,
        ),
      ),
    );
  }
}
