import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/core_providers.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:fixflow_desktop/providers/repair_request_provider.dart';
import 'package:fixflow_desktop/widgets/shared/admin_list_states.dart';
import 'package:fixflow_desktop/widgets/shared/admin_page_scaffold.dart';
import 'package:fixflow_desktop/widgets/shared/app_data_table.dart';
import 'package:fixflow_desktop/widgets/shared/app_pagination.dart';
import 'package:fixflow_desktop/widgets/shared/loading_skeleton.dart';
import 'package:fixflow_desktop/widgets/shared/responsive_filter_bar.dart';
import 'package:fixflow_desktop/widgets/shared/status_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RepairRequestsScreen extends ConsumerStatefulWidget {
  const RepairRequestsScreen({super.key});

  @override
  ConsumerState<RepairRequestsScreen> createState() =>
      _RepairRequestsScreenState();
}

class _RepairRequestsScreenState extends ConsumerState<RepairRequestsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _statusFilter;
  int? _categoryFilter;
  List<LookupResponse>? _categories;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(repairRequestListProvider.notifier).load();
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref
          .read(repairCategoryServiceProvider)
          .getLookup();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } catch (_) {
      // Lookup failure should not block the list.
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(repairRequestListProvider.notifier)
          .setSearch(value.isEmpty ? null : value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repairRequestListProvider);

    return AdminPageScaffold(
      title: 'Zahtjevi za popravku',
      subtitle: 'Pregled prijavljenih kvarova i statusa obrade.',
      filters: _buildFilters(),
      body: _buildBody(state),
      footer: state.totalPages > 1 ? _buildPagination(state) : null,
    );
  }

  Widget _buildFilters() {
    return ResponsiveFilterBar(
      compactBreakpoint: 760,
      primary: _buildSearchField(),
      secondary: [_buildStatusFilter(), _buildCategoryFilter()],
      secondaryWidths: const [172, 172],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: const InputDecoration(
        hintText: 'Pretrazi po opisu, adresi, korisniku...',
        prefixIcon: Icon(LucideIcons.search),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<int?>(
      initialValue: _statusFilter,
      decoration: const InputDecoration(labelText: 'Status'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Svi')),
        ...RepairRequestStatus.values.map(
          (status) => DropdownMenuItem(
            value: status.index,
            child: Text(status.displayName),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _statusFilter = value);
        ref.read(repairRequestListProvider.notifier).setStatusFilter(value);
      },
    );
  }

  Widget _buildCategoryFilter() {
    return DropdownButtonFormField<int?>(
      initialValue: _categoryFilter,
      decoration: const InputDecoration(labelText: 'Kategorija'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Sve')),
        if (_categories != null)
          ..._categories!.map(
            (category) => DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            ),
          ),
      ],
      onChanged: (value) {
        setState(() => _categoryFilter = value);
        ref.read(repairRequestListProvider.notifier).setCategoryFilter(value);
      },
    );
  }

  Widget _buildBody(
    ListState<RepairRequestResponse, RepairRequestQueryFilter> state,
  ) {
    if (state.isLoading && !state.hasData) {
      return const AppTableSkeleton();
    }

    if (state.error != null && !state.hasData) {
      return AdminListErrorState(
        message: state.error!,
        onRetry: () => ref.read(repairRequestListProvider.notifier).load(),
      );
    }

    if (state.isEmpty) {
      return const AdminListEmptyState(text: 'Nema zahtjeva za popravku.');
    }

    return AppDataTable(
      minWidth: 920,
      columns: const [
        DataColumn2(label: Text('ID'), fixedWidth: 70),
        DataColumn2(label: Text('Korisnik'), size: ColumnSize.L),
        DataColumn2(label: Text('Kategorija'), size: ColumnSize.M),
        DataColumn2(label: Text('Status'), fixedWidth: 132),
        DataColumn2(label: Text('Tip'), size: ColumnSize.M),
        DataColumn2(label: Text('Opis'), size: ColumnSize.L),
        DataColumn2(label: Text('Adresa'), size: ColumnSize.L),
        DataColumn2(label: Text('Datum'), fixedWidth: 132),
      ],
      rows: state.items!
          .map(
            (request) => DataRow(
              cells: [
                DataCell(Text('#${request.id}')),
                DataCell(Text(request.customerFullName)),
                DataCell(Text(request.categoryName)),
                DataCell(RepairRequestStatusBadge(status: request.status)),
                DataCell(Text(request.preferenceType.displayName)),
                DataCell(
                  Text(
                    request.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(Text(request.address ?? '-')),
                DataCell(Text(DateFormatter.format(request.createdAt))),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildPagination(
    ListState<RepairRequestResponse, RepairRequestQueryFilter> state,
  ) {
    return AppPagination(
      currentPage: state.filter.pageNumber,
      totalPages: state.totalPages,
      onPrevious: state.filter.pageNumber > 1
          ? () => ref
                .read(repairRequestListProvider.notifier)
                .setPage(state.filter.pageNumber - 1)
          : null,
      onNext: state.filter.pageNumber < state.totalPages
          ? () => ref
                .read(repairRequestListProvider.notifier)
                .setPage(state.filter.pageNumber + 1)
          : null,
    );
  }
}
