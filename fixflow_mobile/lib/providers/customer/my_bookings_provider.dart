import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyBookingsState {
  final List<BookingResponse> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int pageNumber;

  MyBookingsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.pageNumber = 1,
  });

  MyBookingsState copyWith({
    List<BookingResponse>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? pageNumber,
  }) {
    return MyBookingsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class MyBookingsNotifier extends Notifier<MyBookingsState> {
  @override
  MyBookingsState build() => MyBookingsState();

  Future<void> load() async {
    state = MyBookingsState(isLoading: true);
    try {
      final service = ref.read(bookingServiceProvider);
      final result = await service.getMyBookings(
        BookingQueryFilter(pageNumber: 1, pageSize: 20),
      );
      state = MyBookingsState(
        items: result.items,
        hasMore: result.hasNextPage,
        pageNumber: 1,
      );
    } on ApiException catch (e) {
      state = MyBookingsState(error: e.message);
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
}

final myBookingsProvider =
    NotifierProvider<MyBookingsNotifier, MyBookingsState>(
      MyBookingsNotifier.new,
    );
