import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyJobsState {
  final List<BookingResponse> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int pageNumber;

  MyJobsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.pageNumber = 1,
  });

  MyJobsState copyWith({
    List<BookingResponse>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? pageNumber,
  }) {
    return MyJobsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class MyJobsNotifier extends Notifier<MyJobsState> {
  @override
  MyJobsState build() => MyJobsState();

  Future<void> load() async {
    state = MyJobsState(isLoading: true);
    try {
      final service = ref.read(bookingServiceProvider);
      final result = await service.getMyBookings(
        BookingQueryFilter(pageNumber: 1, pageSize: 20),
      );
      state = MyJobsState(
        items: result.items,
        hasMore: result.hasNextPage,
        pageNumber: 1,
      );
    } on ApiException catch (e) {
      state = MyJobsState(error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(bookingServiceProvider);
      final nextPage = state.pageNumber + 1;
      final result = await service.getMyBookings(
        BookingQueryFilter(pageNumber: nextPage, pageSize: 20),
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

  Future<void> updateJobStatus(
    int bookingId,
    UpdateJobStatusRequest request,
  ) async {
    try {
      final service = ref.read(bookingServiceProvider);
      await service.updateJobStatus(bookingId, request);
      await load();
    } on ApiException {
      rethrow;
    }
  }

  Future<void> updateParts(
    int bookingId,
    UpdateBookingPartsRequest request,
  ) async {
    try {
      final service = ref.read(bookingServiceProvider);
      await service.updateParts(bookingId, request);
      await load();
    } on ApiException {
      rethrow;
    }
  }
}

final myJobsProvider = NotifierProvider<MyJobsNotifier, MyJobsState>(
  MyJobsNotifier.new,
);
