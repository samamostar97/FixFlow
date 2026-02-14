import 'package:fixflow_mobile/widgets/shared/loading_skeleton.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_error_state.dart';
import 'package:flutter/material.dart';

class MobilePagedListView<T> extends StatelessWidget {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final ScrollController? controller;
  final Future<void> Function()? onRefresh;
  final VoidCallback onRetry;
  final Widget emptyState;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final EdgeInsetsGeometry padding;
  final Widget? loadingState;
  final Widget? loadMoreIndicator;

  const MobilePagedListView({
    super.key,
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.onRetry,
    required this.emptyState,
    required this.itemBuilder,
    this.errorMessage,
    this.controller,
    this.onRefresh,
    this.padding = const EdgeInsets.all(16),
    this.loadingState,
    this.loadMoreIndicator,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return loadingState ?? AppListSkeleton(padding: padding);
    }

    if (errorMessage != null && items.isEmpty) {
      return MobileErrorState(message: errorMessage!, onRetry: onRetry);
    }

    if (items.isEmpty) {
      return emptyState;
    }

    Widget list = ListView.builder(
      controller: controller,
      padding: padding,
      physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return loadMoreIndicator ?? const _DefaultLoadMoreIndicator();
        }

        return itemBuilder(context, items[index]);
      },
    );

    if (onRefresh != null) {
      list = RefreshIndicator(onRefresh: onRefresh!, child: list);
    }

    return list;
  }
}

class _DefaultLoadMoreIndicator extends StatelessWidget {
  const _DefaultLoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: LinearProgressIndicator(minHeight: 3),
    );
  }
}
