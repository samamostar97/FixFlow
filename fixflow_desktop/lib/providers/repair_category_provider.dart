import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/core_providers.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepairCategoryListNotifier
    extends
        Notifier<ListState<RepairCategoryResponse, RepairCategoryQueryFilter>> {
  @override
  ListState<RepairCategoryResponse, RepairCategoryQueryFilter> build() {
    return ListState(filter: RepairCategoryQueryFilter());
  }

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final service = ref.read(repairCategoryServiceProvider);
      final result = await service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  Future<void> create(CreateRepairCategoryRequest request) async {
    final service = ref.read(repairCategoryServiceProvider);
    await service.create(request.toJson());
    await load();
  }

  Future<void> update(int id, UpdateRepairCategoryRequest request) async {
    final service = ref.read(repairCategoryServiceProvider);
    await service.update(id, request.toJson());
    await load();
  }

  Future<void> delete(int id) async {
    final service = ref.read(repairCategoryServiceProvider);
    await service.delete(id);
    await load();
  }

  void setSearch(String? search) {
    state = state.copyWithFilter(
      state.filter.copyWith(search: search, pageNumber: 1),
    );
    load();
  }

  void setPage(int page) {
    state = state.copyWithFilter(state.filter.copyWith(pageNumber: page));
    load();
  }
}

final repairCategoryListProvider =
    NotifierProvider<
      RepairCategoryListNotifier,
      ListState<RepairCategoryResponse, RepairCategoryQueryFilter>
    >(RepairCategoryListNotifier.new);
