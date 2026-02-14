import 'package:fixflow_desktop/constants/app_motion.dart';
import 'package:fixflow_desktop/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final String? trend;
  final String? meta;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.trend,
    this.meta,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.standardCurve,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: _cardDecoration(),
        child: Stack(
          children: [
            _orb(top: -14, right: -14, size: 68, alpha: 0.10),
            _orb(bottom: -18, right: 28, size: 54, alpha: 0.08),
            _content(context),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      gradient: widget.gradient,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _isHovered ? 0.30 : 0.22),
          blurRadius: _isHovered ? 24 : 18,
          offset: Offset(0, _isHovered ? 14 : 10),
        ),
      ],
    );
  }

  Widget _orb({
    double? top,
    double? bottom,
    required double right,
    required double size,
    required double alpha,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: alpha),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(theme),
        const SizedBox(height: AppSpacing.md),
        Text(
          widget.label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            fontSize: 30,
          ),
        ),
        if (widget.meta != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.meta!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ],
    );
  }

  Widget _header(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, size: 16, color: Colors.white),
        ),
        const Spacer(),
        if (widget.trend != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
            ),
            child: Text(
              widget.trend!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
