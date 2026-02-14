import 'package:fixflow_mobile/widgets/shared/loading_skeleton.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_error_state.dart';
import 'package:flutter/material.dart';

class MobileAsyncStateView<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final T? data;
  final Future<void> Function() onRetry;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final String emptyMessage;

  const MobileAsyncStateView({
    super.key,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.onRetry,
    required this.builder,
    this.loadingWidget,
    this.emptyMessage = 'Podaci nisu dostupni.',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          const AppListSkeleton(itemCount: 4, padding: EdgeInsets.zero);
    }

    if (error != null) {
      return MobileErrorState(message: error!, onRetry: () => onRetry());
    }

    if (data == null) {
      return MobileErrorState(message: emptyMessage, onRetry: () => onRetry());
    }

    return builder(data as T);
  }
}
