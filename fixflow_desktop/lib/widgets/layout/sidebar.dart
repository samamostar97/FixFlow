import 'package:fixflow_desktop/constants/app_density.dart';
import 'package:fixflow_desktop/constants/app_motion.dart';
import 'package:fixflow_desktop/constants/app_spacing.dart';
import 'package:fixflow_desktop/widgets/layout/sidebar_actions.dart';
import 'package:fixflow_desktop/widgets/layout/sidebar_brand_section.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SidebarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? section;

  const SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.section,
  });
}

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;
  final List<SidebarItem> items;
  final bool compact;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
    required this.items,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.standardCurve,
      width: compact
          ? AppDensity.sidebarRailWidth
          : AppDensity.sidebarFullWidth,
      color: cs.surfaceContainerHigh,
      child: Column(
        children: [
          SidebarBrand(compact: compact),
          Divider(color: cs.outline, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: _buildItems(),
            ),
          ),
          Divider(color: cs.outline, height: 1),
          SidebarButton(
            compact: compact,
            icon: LucideIcons.logOut,
            label: 'Odjavi se',
            onTap: onLogout,
            color: cs.onSurfaceVariant,
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    final widgets = <Widget>[];
    String? lastSection;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (!compact && item.section != null && item.section != lastSection) {
        if (lastSection != null) {
          widgets.add(const SizedBox(height: AppSpacing.sm));
        }
        widgets.add(SidebarSectionHeader(label: item.section!));
        lastSection = item.section;
      }

      widgets.add(
        SidebarNavItem(
          compact: compact,
          icon: selectedIndex == i ? item.selectedIcon : item.icon,
          label: item.label,
          isSelected: selectedIndex == i,
          onTap: () => onItemSelected(i),
        ),
      );
    }

    return widgets;
  }
}
