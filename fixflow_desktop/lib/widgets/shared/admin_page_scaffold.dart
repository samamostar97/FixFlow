import 'package:fixflow_desktop/constants/app_breakpoints.dart';
import 'package:fixflow_desktop/constants/app_density.dart';
import 'package:flutter/material.dart';

class AdminPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? filters;
  final Widget? actions;
  final Widget? footer;

  const AdminPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.filters,
    this.actions,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppBreakpoints.pageCompact;
        final edgePadding = isCompact
            ? AppDensity.compactContentGap
            : AppDensity.contentGap;

        return _buildScaffoldContent(context, isCompact, edgePadding);
      },
    );
  }

  Widget _buildScaffoldContent(
    BuildContext context,
    bool isCompact,
    double edgePadding,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, isCompact, edgePadding),
        Expanded(child: body),
        if (footer != null) _buildFooter(edgePadding),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isCompact,
    double edgePadding,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        edgePadding,
        edgePadding,
        edgePadding,
        AppDensity.sectionGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (filters != null || actions != null) ...[
            const SizedBox(height: AppDensity.fieldGap),
            _buildToolbar(isCompact),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(double edgePadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        edgePadding,
        AppDensity.fieldGap,
        edgePadding,
        0,
      ),
      child: footer!,
    );
  }

  Widget _buildToolbar(bool isCompact) {
    if (isCompact) {
      final children = <Widget>[];
      if (filters != null) {
        children.add(filters!);
      }
      if (filters != null && actions != null) {
        children.add(const SizedBox(height: AppDensity.fieldGap));
      }
      if (actions != null) {
        children.add(Align(alignment: Alignment.centerLeft, child: actions!));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    final children = <Widget>[];
    if (filters != null) {
      children.add(Expanded(child: filters!));
    }
    if (filters != null && actions != null) {
      children.add(const SizedBox(width: AppDensity.fieldGap));
    }
    if (actions != null) {
      children.add(Align(alignment: Alignment.topRight, child: actions!));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
