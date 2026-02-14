import 'package:fixflow_core/fixflow_core.dart';

class ListState<T, F extends BaseQueryFilter> {
  final PagedResult<T>? data;
  final bool isLoading;
  final String? error;
  final F filter;

  ListState({
    this.data,
    this.isLoading = false,
    this.error,
    required this.filter,
  });

  List<T>? get items => data?.items;
  int get totalCount => data?.totalCount ?? 0;
  int get totalPages => data?.totalPages ?? 0;
  bool get hasData => data != null && data!.items.isNotEmpty;
  bool get isEmpty => data != null && data!.items.isEmpty;

  ListState<T, F> copyWithLoading() {
    return ListState(data: data, isLoading: true, error: null, filter: filter);
  }

  ListState<T, F> copyWithData(PagedResult<T> result) {
    return ListState(
      data: result,
      isLoading: false,
      error: null,
      filter: filter,
    );
  }

  ListState<T, F> copyWithError(String message) {
    return ListState(
      data: data,
      isLoading: false,
      error: message,
      filter: filter,
    );
  }

  ListState<T, F> copyWithFilter(F newFilter) {
    return ListState(
      data: data,
      isLoading: isLoading,
      error: error,
      filter: newFilter,
    );
  }
}
