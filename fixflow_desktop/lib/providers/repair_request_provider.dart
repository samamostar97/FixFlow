import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/core_providers.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepairRequestListNotifier
    extends
        Notifier<ListState<RepairRequestResponse, RepairRequestQueryFilter>> {
  @override
  ListState<RepairRequestResponse, RepairRequestQueryFilter> build() {
    return ListState(filter: RepairRequestQueryFilter());
  }

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final service = ref.read(repairRequestServiceProvider);
      final result = await service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  Future<void> delete(int id) async {
    final service = ref.read(repairRequestServiceProvider);
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
      RepairRequestQueryFilter(
        pageNumber: 1,
        pageSize: state.filter.pageSize,
        search: state.filter.search,
        status: status,
        categoryId: state.filter.categoryId,
      ),
    );
    load();
  }

  void setCategoryFilter(int? categoryId) {
    state = state.copyWithFilter(
      RepairRequestQueryFilter(
        pageNumber: 1,
        pageSize: state.filter.pageSize,
        search: state.filter.search,
        status: state.filter.status,
        categoryId: categoryId,
      ),
    );
    load();
  }

  void setPage(int page) {
    state = state.copyWithFilter(state.filter.copyWith(pageNumber: page));
    load();
  }
}

final repairRequestListProvider =
    NotifierProvider<
      RepairRequestListNotifier,
      ListState<RepairRequestResponse, RepairRequestQueryFilter>
    >(RepairRequestListNotifier.new);
