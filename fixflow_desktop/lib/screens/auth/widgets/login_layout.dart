import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginLayout extends StatelessWidget {
  final Widget formPanel;

  const LoginLayout({super.key, required this.formPanel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackground(context),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 760) {
                    return _buildCompactCard(context);
                  }
                  return _buildWideCard(context);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.surfaceContainerHigh, cs.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _bgOrb(const Color(0xFF22D3EE), 280, 0.16),
          ),
          Positioned(
            bottom: -140,
            right: -40,
            child: _bgOrb(const Color(0xFF7C3AED), 320, 0.14),
          ),
          Positioned(
            top: 180,
            right: 220,
            child: _bgOrb(const Color(0xFF10B981), 120, 0.12),
          ),
        ],
      ),
    );
  }

  Widget _buildWideCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(flex: 5, child: _buildBrandPanel(context)),
            VerticalDivider(width: 1, color: cs.outline),
            Expanded(flex: 4, child: formPanel),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBrandPanel(context, compact: true),
          Divider(height: 1, color: cs.outline),
          formPanel,
        ],
      ),
    );
  }

  Widget _bgOrb(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildBrandPanel(BuildContext context, {bool compact = false}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.all(compact ? 22 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(LucideIcons.wrench, color: cs.primary),
          ),
          const SizedBox(height: 20),
          Text('FixFlow Admin', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Kontrolni centar za zahtjeve, ponude i verifikaciju majstora.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _brandFeature(
            context,
            LucideIcons.shieldCheck,
            'Sigurna role kontrola',
          ),
          const SizedBox(height: 10),
          _brandFeature(
            context,
            LucideIcons.activity,
            'Pregled statusa u realnom vremenu',
          ),
          const SizedBox(height: 10),
          _brandFeature(
            context,
            LucideIcons.layoutGrid,
            'Konzistentni admin workflow',
          ),
        ],
      ),
    );
  }

  Widget _brandFeature(BuildContext context, IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
