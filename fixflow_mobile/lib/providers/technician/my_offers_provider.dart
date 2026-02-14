import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyOffersState {
  final List<OfferResponse> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int pageNumber;

  MyOffersState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.pageNumber = 1,
  });

  MyOffersState copyWith({
    List<OfferResponse>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? pageNumber,
  }) {
    return MyOffersState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class MyOffersNotifier extends Notifier<MyOffersState> {
  @override
  MyOffersState build() => MyOffersState();

  Future<void> load() async {
    state = MyOffersState(isLoading: true);
    try {
      final service = ref.read(offerServiceProvider);
      final result = await service.getMyOffers(
        OfferQueryFilter(pageNumber: 1, pageSize: 20),
      );
      state = MyOffersState(
        items: result.items,
        hasMore: result.hasNextPage,
        pageNumber: 1,
      );
    } on ApiException catch (e) {
      state = MyOffersState(error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(offerServiceProvider);
      final nextPage = state.pageNumber + 1;
      final result = await service.getMyOffers(
        OfferQueryFilter(pageNumber: nextPage, pageSize: 20),
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

final myOffersProvider = NotifierProvider<MyOffersNotifier, MyOffersState>(
  MyOffersNotifier.new,
);
