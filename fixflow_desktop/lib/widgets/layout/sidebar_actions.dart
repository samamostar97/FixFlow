import 'package:fixflow_desktop/constants/app_motion.dart';
import 'package:fixflow_desktop/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class SidebarNavItem extends StatefulWidget {
  final bool compact;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarNavItem({
    super.key,
    required this.compact,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);
    final tile = _buildTile(context, content);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.compact
          ? Tooltip(message: widget.label, child: tile)
          : tile,
    );
  }

  Widget _buildContent(BuildContext context) {
    final fgColor = _resolveFgColor(context);
    if (widget.compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
        child: Icon(widget.icon, size: 18, color: fgColor),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Icon(widget.icon, size: 18, color: fgColor),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(
                color: fgColor,
                fontSize: 13,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, Widget navContent) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standardCurve,
        margin: EdgeInsets.symmetric(
          horizontal: widget.compact ? AppSpacing.xs : AppSpacing.sm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: _resolveBgColor(context),
          borderRadius: BorderRadius.circular(8),
          border: widget.isSelected ? Border.all(color: cs.outline) : null,
        ),
        child: navContent,
      ),
    );
  }

  Color _resolveBgColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (widget.isSelected) {
      return cs.primary.withValues(alpha: 0.12);
    }
    if (_isHovered) {
      return cs.surfaceContainerLow.withValues(alpha: 0.4);
    }
    return Colors.transparent;
  }

  Color _resolveFgColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return widget.isSelected ? cs.primary : cs.onSurfaceVariant;
  }
}

class SidebarButton extends StatelessWidget {
  final bool compact;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const SidebarButton({
    super.key,
    required this.compact,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = compact ? _buildCompactContent() : _buildExpandedContent();
    final child = InkWell(onTap: onTap, child: content);
    if (!compact) {
      return child;
    }
    return Tooltip(message: label, child: child);
  }

  Widget _buildCompactContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm + 4),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
