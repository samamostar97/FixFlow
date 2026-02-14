import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/booking_provider.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
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

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _jobStatusFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bookingListProvider.notifier).load());
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
          .read(bookingListProvider.notifier)
          .setSearch(value.isEmpty ? null : value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingListProvider);

    return AdminPageScaffold(
      title: 'Poslovi',
      subtitle: 'Pregled aktivnih i zavrsenih servisa.',
      filters: _buildFilters(),
      body: _buildBody(state),
      footer: state.totalPages > 1 ? _buildPagination(state) : null,
    );
  }

  Widget _buildFilters() {
    return ResponsiveFilterBar(
      compactBreakpoint: 760,
      primary: _buildSearchField(),
      secondary: [_buildJobStatusFilter()],
      secondaryWidths: const [172],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: const InputDecoration(
        hintText: 'Pretrazi po korisniku, majstoru...',
        prefixIcon: Icon(LucideIcons.search),
      ),
    );
  }

  Widget _buildJobStatusFilter() {
    return DropdownButtonFormField<int?>(
      initialValue: _jobStatusFilter,
      decoration: const InputDecoration(labelText: 'Status posla'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Svi')),
        ...JobStatus.values.map(
          (status) => DropdownMenuItem(
            value: status.index,
            child: Text(status.displayName),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _jobStatusFilter = value);
        ref.read(bookingListProvider.notifier).setJobStatusFilter(value);
      },
    );
  }

  Widget _buildBody(ListState<BookingResponse, BookingQueryFilter> state) {
    if (state.isLoading && !state.hasData) {
      return const AppTableSkeleton();
    }

    if (state.error != null && !state.hasData) {
      return AdminListErrorState(
        message: state.error!,
        onRetry: () => ref.read(bookingListProvider.notifier).load(),
      );
    }

    if (state.isEmpty) {
      return const AdminListEmptyState(
        text: 'Nema poslova.',
        icon: LucideIcons.briefcase,
      );
    }

    return AppDataTable(
      minWidth: 960,
      columns: const [
        DataColumn2(label: Text('ID'), fixedWidth: 70),
        DataColumn2(label: Text('Korisnik'), size: ColumnSize.L),
        DataColumn2(label: Text('Majstor'), size: ColumnSize.L),
        DataColumn2(label: Text('Kategorija'), size: ColumnSize.S),
        DataColumn2(label: Text('Status'), fixedWidth: 130),
        DataColumn2(label: Text('Dijelovi'), size: ColumnSize.L),
        DataColumn2(label: Text('Ukupno'), fixedWidth: 110),
        DataColumn2(label: Text('Datum'), fixedWidth: 132),
      ],
      rows: state.items!
          .map(
            (booking) => DataRow(
              cells: [
                DataCell(Text('#${booking.id}')),
                DataCell(Text(booking.customerFullName)),
                DataCell(Text(booking.technicianFullName)),
                DataCell(Text(booking.repairRequestCategoryName)),
                DataCell(JobStatusBadge(status: booking.jobStatus)),
                DataCell(
                  Text(
                    booking.partsDescription ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(Text(CurrencyFormatter.format(booking.totalAmount))),
                DataCell(Text(DateFormatter.format(booking.createdAt))),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildPagination(
    ListState<BookingResponse, BookingQueryFilter> state,
  ) {
    return AppPagination(
      currentPage: state.filter.pageNumber,
      totalPages: state.totalPages,
      onPrevious: state.filter.pageNumber > 1
          ? () => ref
                .read(bookingListProvider.notifier)
                .setPage(state.filter.pageNumber - 1)
          : null,
      onNext: state.filter.pageNumber < state.totalPages
          ? () => ref
                .read(bookingListProvider.notifier)
                .setPage(state.filter.pageNumber + 1)
          : null,
    );
  }
}
