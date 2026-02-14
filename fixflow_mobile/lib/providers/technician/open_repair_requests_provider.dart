import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OpenRepairRequestsState {
  final List<RepairRequestResponse> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int pageNumber;

  OpenRepairRequestsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.pageNumber = 1,
  });

  OpenRepairRequestsState copyWith({
    List<RepairRequestResponse>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? pageNumber,
  }) {
    return OpenRepairRequestsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class OpenRepairRequestsNotifier extends Notifier<OpenRepairRequestsState> {
  @override
  OpenRepairRequestsState build() => OpenRepairRequestsState();

  Future<void> load() async {
    state = OpenRepairRequestsState(isLoading: true);
    try {
      final service = ref.read(repairRequestServiceProvider);
      final result = await service.getOpenRequests(
        RepairRequestQueryFilter(pageNumber: 1, pageSize: 20),
      );
      state = OpenRepairRequestsState(
        items: result.items,
        hasMore: result.hasNextPage,
        pageNumber: 1,
      );
    } on ApiException catch (e) {
      state = OpenRepairRequestsState(error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(repairRequestServiceProvider);
      final nextPage = state.pageNumber + 1;
      final result = await service.getOpenRequests(
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
}

final openRepairRequestsProvider =
    NotifierProvider<OpenRepairRequestsNotifier, OpenRepairRequestsState>(
      OpenRepairRequestsNotifier.new,
    );
