import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/core_providers.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingListNotifier
    extends Notifier<ListState<BookingResponse, BookingQueryFilter>> {
  @override
  ListState<BookingResponse, BookingQueryFilter> build() {
    return ListState(filter: BookingQueryFilter());
  }

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final service = ref.read(bookingServiceProvider);
      final result = await service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  void setSearch(String? search) {
    state = state.copyWithFilter(
      state.filter.copyWith(search: search, pageNumber: 1),
    );
    load();
  }

  void setJobStatusFilter(int? jobStatus) {
    state = state.copyWithFilter(
      BookingQueryFilter(
        pageNumber: 1,
        pageSize: state.filter.pageSize,
        search: state.filter.search,
        jobStatus: jobStatus,
        customerId: state.filter.customerId,
        technicianId: state.filter.technicianId,
      ),
    );
    load();
  }

  void setPage(int page) {
    state = state.copyWithFilter(state.filter.copyWith(pageNumber: page));
    load();
  }
}

final bookingListProvider =
    NotifierProvider<
      BookingListNotifier,
      ListState<BookingResponse, BookingQueryFilter>
    >(BookingListNotifier.new);
