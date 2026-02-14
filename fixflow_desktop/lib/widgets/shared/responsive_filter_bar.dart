import 'package:flutter/material.dart';

class ResponsiveFilterBar extends StatelessWidget {
  final double compactBreakpoint;
  final Widget primary;
  final List<Widget> secondary;
  final List<double>? secondaryWidths;
  final bool primaryExpanded;
  final double spacing;

  const ResponsiveFilterBar({
    super.key,
    required this.compactBreakpoint,
    required this.primary,
    this.secondary = const [],
    this.secondaryWidths,
    this.primaryExpanded = true,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < compactBreakpoint;
        if (compact) {
          return _buildCompact(constraints.maxWidth);
        }
        return _buildWide();
      },
    );
  }

  Widget _buildCompact(double maxWidth) {
    final children = <Widget>[primary];

    if (secondary.isNotEmpty) {
      children.add(SizedBox(height: spacing));
      children.add(
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < secondary.length; i++)
              SizedBox(
                width: _compactSecondaryWidth(maxWidth, i),
                child: secondary[i],
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildWide() {
    final children = <Widget>[
      if (primaryExpanded) Expanded(child: primary) else primary,
    ];

    for (var i = 0; i < secondary.length; i++) {
      children.add(SizedBox(width: spacing));
      final width = secondaryWidths != null && i < secondaryWidths!.length
          ? secondaryWidths![i]
          : null;
      if (width == null) {
        children.add(secondary[i]);
      } else {
        children.add(SizedBox(width: width, child: secondary[i]));
      }
    }

    return Row(children: children);
  }

  double _compactSecondaryWidth(double maxWidth, int index) {
    final configuredWidth =
        secondaryWidths != null && index < secondaryWidths!.length
        ? secondaryWidths![index]
        : 200.0;

    if (maxWidth >= 520) {
      final availablePerItem = (maxWidth - spacing) / 2;
      return configuredWidth < availablePerItem
          ? configuredWidth
          : availablePerItem;
    }

    return maxWidth;
  }
}
