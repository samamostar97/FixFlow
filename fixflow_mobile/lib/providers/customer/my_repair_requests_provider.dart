import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyRepairRequestsState {
  final List<RepairRequestResponse> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int pageNumber;

  MyRepairRequestsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.pageNumber = 1,
  });

  MyRepairRequestsState copyWith({
    List<RepairRequestResponse>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? pageNumber,
  }) {
    return MyRepairRequestsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class MyRepairRequestsNotifier extends Notifier<MyRepairRequestsState> {
  @override
  MyRepairRequestsState build() => MyRepairRequestsState();

  Future<void> load() async {
    state = MyRepairRequestsState(isLoading: true);
    try {
      final service = ref.read(repairRequestServiceProvider);
      final result = await service.getMyRequests(
        RepairRequestQueryFilter(pageNumber: 1, pageSize: 20),
      );
      state = MyRepairRequestsState(
        items: result.items,
        hasMore: result.hasNextPage,
        pageNumber: 1,
      );
    } on ApiException catch (e) {
      state = MyRepairRequestsState(error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(repairRequestServiceProvider);
      final nextPage = state.pageNumber + 1;
      final result = await service.getMyRequests(
        RepairRequestQueryFilter(pageNumber: nextPage, pageSize: 20),
      );
      state = state.copyWith(
        items: [...state.items, ...result.items],
        isLoading: false,
        hasMore: result.hasNextPage,
        pageNumber: nextPage,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> cancel(int id) async {
    final service = ref.read(repairRequestServiceProvider);
    await service.cancel(id);
    await load();
  }
}

final myRepairRequestsProvider =
    NotifierProvider<MyRepairRequestsNotifier, MyRepairRequestsState>(
      MyRepairRequestsNotifier.new,
    );
