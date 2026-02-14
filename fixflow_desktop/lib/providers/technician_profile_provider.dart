import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/core_providers.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TechnicianProfileListNotifier
    extends
        Notifier<
          ListState<TechnicianProfileResponse, TechnicianProfileQueryFilter>
        > {
  @override
  ListState<TechnicianProfileResponse, TechnicianProfileQueryFilter> build() {
    return ListState(filter: TechnicianProfileQueryFilter());
  }

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final service = ref.read(technicianProfileServiceProvider);
      final result = await service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    }
  }

  Future<void> verify(int id) async {
    final service = ref.read(technicianProfileServiceProvider);
    await service.verify(id);
    await load();
  }

  void setSearch(String? search) {
    state = state.copyWithFilter(
      state.filter.copyWith(search: search, pageNumber: 1),
    );
    load();
  }

  void setVerifiedFilter(bool? isVerified) {
    state = state.copyWithFilter(
      state.filter.copyWith(isVerified: isVerified, pageNumber: 1),
    );
    load();
  }

  void setPage(int page) {
    state = state.copyWithFilter(state.filter.copyWith(pageNumber: page));
    load();
  }
}

final technicianProfileListProvider =
    NotifierProvider<
      TechnicianProfileListNotifier,
      ListState<TechnicianProfileResponse, TechnicianProfileQueryFilter>
    >(TechnicianProfileListNotifier.new);
