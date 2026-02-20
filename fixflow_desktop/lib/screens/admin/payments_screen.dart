import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:fixflow_desktop/providers/payment_provider.dart';
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

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _statusFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(paymentListProvider.notifier).load());
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
          .read(paymentListProvider.notifier)
          .setSearch(value.isEmpty ? null : value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentListProvider);

    return AdminPageScaffold(
      title: 'Uplate',
      subtitle: 'Pregled svih uplata',
      filters: _buildFilters(),
      body: _buildBody(state),
      footer: state.totalPages > 1 ? _buildPagination(state) : null,
    );
  }

  Widget _buildFilters() {
    return ResponsiveFilterBar(
      compactBreakpoint: 760,
      primary: _buildSearchField(),
      secondary: [_buildStatusFilter()],
      secondaryWidths: const [172],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: const InputDecoration(
        hintText: 'Pretrazi po korisniku...',
        prefixIcon: Icon(LucideIcons.search),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<int?>(
      isExpanded: true,
      initialValue: _statusFilter,
      decoration: const InputDecoration(labelText: 'Status'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Svi')),
        ...PaymentStatus.values.map(
          (status) => DropdownMenuItem(
            value: status.index,
            child: Text(status.displayName),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _statusFilter = value);
        ref.read(paymentListProvider.notifier).setStatusFilter(value);
      },
    );
  }

  Widget _buildBody(
    ListState<PaymentResponse, PaymentQueryFilter> state,
  ) {
    if (state.isLoading && !state.hasData) {
      return const AppTableSkeleton();
    }

    if (state.error != null && !state.hasData) {
      return AdminListErrorState(
        message: state.error!,
        onRetry: () => ref.read(paymentListProvider.notifier).load(),
      );
    }

    if (state.isEmpty) {
      return const AdminListEmptyState(
        text: 'Nema uplata.',
        icon: LucideIcons.creditCard,
      );
    }

    return AppDataTable(
      minWidth: 820,
      columns: const [
        DataColumn2(label: Text('ID'), fixedWidth: 70),
        DataColumn2(label: Text('Korisnik'), size: ColumnSize.L),
        DataColumn2(label: Text('Iznos'), fixedWidth: 120),
        DataColumn2(label: Text('Tip'), fixedWidth: 120),
        DataColumn2(label: Text('Status'), fixedWidth: 120),
        DataColumn2(label: Text('Datum'), fixedWidth: 132),
      ],
      rows: state.items!
          .map(
            (payment) => DataRow(
              cells: [
                DataCell(Text('#${payment.id}')),
                DataCell(Text(payment.userFullName)),
                DataCell(Text(CurrencyFormatter.format(payment.amount))),
                DataCell(Text(payment.type.displayName)),
                DataCell(PaymentStatusBadge(status: payment.status)),
                DataCell(Text(DateFormatter.format(payment.createdAt))),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildPagination(
    ListState<PaymentResponse, PaymentQueryFilter> state,
  ) {
    return AppPagination(
      currentPage: state.filter.pageNumber,
      totalPages: state.totalPages,
      onPrevious: state.filter.pageNumber > 1
          ? () => ref
                .read(paymentListProvider.notifier)
                .setPage(state.filter.pageNumber - 1)
          : null,
      onNext: state.filter.pageNumber < state.totalPages
          ? () => ref
                .read(paymentListProvider.notifier)
                .setPage(state.filter.pageNumber + 1)
          : null,
    );
  }
}
