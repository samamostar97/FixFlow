import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:fixflow_desktop/providers/offer_provider.dart';
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

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _statusFilter;
  int? _serviceTypeFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(offerListProvider.notifier).load());
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
          .read(offerListProvider.notifier)
          .setSearch(value.isEmpty ? null : value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offerListProvider);

    return AdminPageScaffold(
      title: 'Ponude',
      subtitle: 'Pregled ponuda majstora i njihovih statusa.',
      filters: _buildFilters(),
      body: _buildBody(state),
      footer: state.totalPages > 1 ? _buildPagination(state) : null,
    );
  }

  Widget _buildFilters() {
    return ResponsiveFilterBar(
      compactBreakpoint: 760,
      primary: _buildSearchField(),
      secondary: [_buildStatusFilter(), _buildServiceTypeFilter()],
      secondaryWidths: const [172, 172],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: const InputDecoration(
        hintText: 'Pretrazi po majstoru, napomeni...',
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
        ...OfferStatus.values.map(
          (status) => DropdownMenuItem(
            value: status.index,
            child: Text(status.displayName),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _statusFilter = value);
        ref.read(offerListProvider.notifier).setStatusFilter(value);
      },
    );
  }

  Widget _buildServiceTypeFilter() {
    return DropdownButtonFormField<int?>(
      initialValue: _serviceTypeFilter,
      decoration: const InputDecoration(labelText: 'Tip usluge'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Svi')),
        ...ServiceType.values.map(
          (serviceType) => DropdownMenuItem(
            value: serviceType.index,
            child: Text(serviceType.displayName),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _serviceTypeFilter = value);
        ref.read(offerListProvider.notifier).setServiceTypeFilter(value);
      },
    );
  }

  Widget _buildBody(ListState<OfferResponse, OfferQueryFilter> state) {
    if (state.isLoading && !state.hasData) {
      return const AppTableSkeleton();
    }

    if (state.error != null && !state.hasData) {
      return AdminListErrorState(
        message: state.error!,
        onRetry: () => ref.read(offerListProvider.notifier).load(),
      );
    }

    if (state.isEmpty) {
      return const AdminListEmptyState(text: 'Nema ponuda.');
    }

    return AppDataTable(
      minWidth: 920,
      columns: const [
        DataColumn2(label: Text('ID'), fixedWidth: 70),
        DataColumn2(label: Text('Majstor'), size: ColumnSize.L),
        DataColumn2(label: Text('Status'), fixedWidth: 132),
        DataColumn2(label: Text('Zahtjev'), size: ColumnSize.L),
        DataColumn2(label: Text('Cijena'), fixedWidth: 110),
        DataColumn2(label: Text('Dani'), fixedWidth: 90),
        DataColumn2(label: Text('Tip usluge'), fixedWidth: 120),
        DataColumn2(label: Text('Datum'), fixedWidth: 132),
      ],
      rows: state.items!
          .map(
            (offer) => DataRow(
              cells: [
                DataCell(Text('#${offer.id}')),
                DataCell(Text(offer.technicianFullName)),
                DataCell(OfferStatusBadge(status: offer.status)),
                DataCell(
                  Text(
                    '#${offer.repairRequestId} - ${offer.repairRequestCategoryName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(Text(CurrencyFormatter.format(offer.price))),
                DataCell(Text('${offer.estimatedDays}')),
                DataCell(Text(offer.serviceType.displayName)),
                DataCell(Text(DateFormatter.format(offer.createdAt))),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildPagination(ListState<OfferResponse, OfferQueryFilter> state) {
    return AppPagination(
      currentPage: state.filter.pageNumber,
      totalPages: state.totalPages,
      onPrevious: state.filter.pageNumber > 1
          ? () => ref
                .read(offerListProvider.notifier)
                .setPage(state.filter.pageNumber - 1)
          : null,
      onNext: state.filter.pageNumber < state.totalPages
          ? () => ref
                .read(offerListProvider.notifier)
                .setPage(state.filter.pageNumber + 1)
          : null,
    );
  }
}
