import 'package:flutter/material.dart';
import 'package:fixflow_mobile/constants/app_density.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';

class MobilePageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final EdgeInsetsGeometry contentPadding;
  final Future<void> Function()? onRefresh;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool useSafeArea;
  final bool scrollable;

  const MobilePageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.leading,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AppDensity.pageHorizontalPadding,
      vertical: AppDensity.pageVerticalPadding,
    ),
    this.onRefresh,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.useSafeArea = true,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = _buildContent(context);

    if (onRefresh != null) {
      content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    }

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions, leading: leading),
      body: content,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildContent(BuildContext context) {
    final subtitleBlock = _buildSubtitle(context);
    final subtitleWidgets = <Widget>[
      ...?subtitleBlock == null
          ? null
          : <Widget>[subtitleBlock, const SizedBox(height: AppSpacing.md)],
    ];

    if (scrollable) {
      return SingleChildScrollView(
        padding: contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...subtitleWidgets, body],
        ),
      );
    }

    return Padding(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...subtitleWidgets,
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    if (subtitle == null) {
      return null;
    }

    return Text(
      subtitle!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
