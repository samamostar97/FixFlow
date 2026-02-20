import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/core_providers.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentListNotifier
    extends Notifier<ListState<PaymentResponse, PaymentQueryFilter>> {
  @override
  ListState<PaymentResponse, PaymentQueryFilter> build() {
    return ListState(filter: PaymentQueryFilter());
  }

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final service = ref.read(paymentServiceProvider);
      final result = await service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  PaymentQueryFilter _buildFilter({
    int? pageNumber,
    String? search,
    int? status,
  }) {
    final f = PaymentQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: state.filter.pageSize,
      status: status ?? state.filter.status,
      type: state.filter.type,
      bookingId: state.filter.bookingId,
      userId: state.filter.userId,
    );
    f.search = search ?? state.filter.search;
    return f;
  }

  void setSearch(String? search) {
    state = state.copyWithFilter(
      _buildFilter(pageNumber: 1, search: search),
    );
    load();
  }

  void setStatusFilter(int? status) {
    state = state.copyWithFilter(
      _buildFilter(pageNumber: 1, status: status),
    );
    load();
  }

  void setPage(int page) {
    state = state.copyWithFilter(_buildFilter(pageNumber: page));
    load();
  }
}

final paymentListProvider = NotifierProvider<
    PaymentListNotifier,
    ListState<PaymentResponse, PaymentQueryFilter>>(PaymentListNotifier.new);
