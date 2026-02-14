import 'package:fixflow_mobile/constants/app_density.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MobileAuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeText;
  final Widget child;
  final Widget? footer;
  final bool showBackButton;
  final VoidCallback? onBack;

  const MobileAuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.badgeText,
    this.footer,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF08142B), Color(0xFF060F20), Color(0xFF050B17)],
          ),
        ),
        child: Stack(
          children: [
            const _AuthOrb(top: -70, right: -50, size: 220, color: 0x1F2CD6FF),
            const _AuthOrb(
              bottom: -110,
              left: -70,
              size: 260,
              color: 0x1A9B6BFF,
            ),
            SafeArea(child: _buildScrollBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDensity.pageHorizontalPadding,
          AppSpacing.lg,
          AppDensity.pageHorizontalPadding,
          AppSpacing.lg,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showBackButton) _buildBackButton(context),
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),
              MobileSectionCard(
                padding: const EdgeInsets.all(18),
                child: child,
              ),
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.md),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(LucideIcons.arrowLeft),
        tooltip: 'Nazad',
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badgeText != null) ...[
          _AuthBadge(text: badgeText!),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(title, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        ),
      ],
    );
  }
}

class _AuthBadge extends StatelessWidget {
  final String text;

  const _AuthBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AuthOrb extends StatelessWidget {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double size;
  final int color;

  const _AuthOrb({
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(color), const Color(0x00000000)],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
