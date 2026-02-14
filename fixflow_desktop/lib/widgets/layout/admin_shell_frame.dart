import 'package:fixflow_desktop/constants/app_breakpoints.dart';
import 'package:fixflow_desktop/constants/app_density.dart';
import 'package:fixflow_desktop/widgets/layout/sidebar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdminShellFrame extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;
  final List<SidebarItem> items;
  final Widget child;

  const AdminShellFrame({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
    required this.items,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isRail = constraints.maxWidth < AppBreakpoints.sidebarRail;
        final contentGap = isRail
            ? AppDensity.compactContentGap
            : AppDensity.contentGap;
        final body = Row(
          children: [
            Sidebar(
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
              onLogout: onLogout,
              items: items,
              compact: isRail,
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            Expanded(
              child: Padding(padding: EdgeInsets.all(contentGap), child: child),
            ),
          ],
        );

        if (kReleaseMode) {
          return body;
        }

        return Stack(
          children: [
            body,
            Positioned(
              top: 8,
              right: 8,
              child: IgnorePointer(
                child: _WidthDebugBadge(
                  widthPx: constraints.maxWidth,
                  isRail: isRail,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WidthDebugBadge extends StatelessWidget {
  final double widthPx;
  final bool isRail;

  const _WidthDebugBadge({required this.widthPx, required this.isRail});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline),
      ),
      child: Text(
        'Sirina: ${widthPx.round()}px  |  Sidebar: ${isRail ? "rail" : "full"}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
