import 'package:fixflow_mobile/constants/app_density.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class MobileTopTabsSection extends StatelessWidget {
  final List<Tab> tabs;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final double gapBelowHeader;

  const MobileTopTabsSection({
    super.key,
    required this.tabs,
    required this.children,
    this.margin,
    this.gapBelowHeader = AppSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      tabs.length == children.length,
      'tabs and children must have same length',
    );

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Container(
            margin:
                margin ??
                const EdgeInsets.fromLTRB(
                  AppDensity.pageHorizontalPadding,
                  AppSpacing.sm,
                  AppDensity.pageHorizontalPadding,
                  0,
                ),
            decoration: _headerDecoration(context),
            child: TabBar(
              tabs: tabs,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: _tabIndicator(context),
              labelStyle: Theme.of(context).textTheme.labelLarge,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: gapBelowHeader),
          Expanded(child: TabBarView(children: children)),
        ],
      ),
    );
  }

  BoxDecoration _headerDecoration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BoxDecoration(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: cs.outline),
    );
  }

  Decoration _tabIndicator(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: cs.surfaceContainerHigh,
    );
  }
}
