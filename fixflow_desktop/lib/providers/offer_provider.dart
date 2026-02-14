import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/core_providers.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfferListNotifier
    extends Notifier<ListState<OfferResponse, OfferQueryFilter>> {
  @override
  ListState<OfferResponse, OfferQueryFilter> build() {
    return ListState(filter: OfferQueryFilter());
  }

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final service = ref.read(offerServiceProvider);
      final result = await service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  Future<void> delete(int id) async {
    final service = ref.read(offerServiceProvider);
    await service.delete(id);
    await load();
  }

  void setSearch(String? search) {
    state = state.copyWithFilter(
      state.filter.copyWith(search: search, pageNumber: 1),
    );
    load();
  }

  void setStatusFilter(int? status) {
    state = state.copyWithFilter(
      OfferQueryFilter(
        pageNumber: 1,
        pageSize: state.filter.pageSize,
        search: state.filter.search,
        status: status,
        serviceType: state.filter.serviceType,
      ),
    );
    load();
  }

  void setServiceTypeFilter(int? serviceType) {
    state = state.copyWithFilter(
      OfferQueryFilter(
        pageNumber: 1,
        pageSize: state.filter.pageSize,
        search: state.filter.search,
        status: state.filter.status,
        serviceType: serviceType,
      ),
    );
    load();
  }

  void setPage(int page) {
    state = state.copyWithFilter(state.filter.copyWith(pageNumber: page));
    load();
  }
}

final offerListProvider =
    NotifierProvider<
      OfferListNotifier,
      ListState<OfferResponse, OfferQueryFilter>
    >(OfferListNotifier.new);
