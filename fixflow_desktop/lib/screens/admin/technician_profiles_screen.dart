import 'package:data_table_2/data_table_2.dart';
import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:fixflow_desktop/providers/technician_profile_provider.dart';
import 'package:fixflow_desktop/screens/admin/widgets/technician_profile_table_cells.dart';
import 'package:fixflow_desktop/widgets/shared/admin_list_states.dart';
import 'package:fixflow_desktop/widgets/shared/admin_page_scaffold.dart';
import 'package:fixflow_desktop/widgets/shared/app_data_table.dart';
import 'package:fixflow_desktop/widgets/shared/app_pagination.dart';
import 'package:fixflow_desktop/widgets/shared/loading_skeleton.dart';
import 'package:fixflow_desktop/widgets/shared/responsive_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TechnicianProfilesScreen extends ConsumerStatefulWidget {
  const TechnicianProfilesScreen({super.key});

  @override
  ConsumerState<TechnicianProfilesScreen> createState() =>
      _TechnicianProfilesScreenState();
}

class _TechnicianProfilesScreenState
    extends ConsumerState<TechnicianProfilesScreen> {
  final _searchController = TextEditingController();
  bool? _verifiedFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(technicianProfileListProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(technicianProfileListProvider);

    return AdminPageScaffold(
      title: 'Profili majstora',
      subtitle: 'Verifikacija i pregled podataka tehnicara.',
      filters: _buildFilters(),
      body: _buildContent(listState),
      footer: listState.totalPages > 1 ? _buildPagination(listState) : null,
    );
  }

  Widget _buildFilters() {
    return ResponsiveFilterBar(
      compactBreakpoint: 760,
      primary: _buildSearchField(),
      secondary: [_buildVerifiedFilter()],
      secondaryWidths: const [172],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        hintText: 'Pretrazi po imenu, emailu ili specijalnostima...',
        prefixIcon: Icon(LucideIcons.search),
      ),
      onChanged: (value) {
        ref
            .read(technicianProfileListProvider.notifier)
            .setSearch(value.isEmpty ? null : value);
      },
    );
  }

  Widget _buildVerifiedFilter() {
    return DropdownButtonFormField<bool?>(
      decoration: const InputDecoration(labelText: 'Status'),
      initialValue: _verifiedFilter,
      items: const [
        DropdownMenuItem(value: null, child: Text('Svi')),
        DropdownMenuItem(value: true, child: Text('Verificirani')),
        DropdownMenuItem(value: false, child: Text('Neverificirani')),
      ],
      onChanged: (value) {
        setState(() => _verifiedFilter = value);
        ref
            .read(technicianProfileListProvider.notifier)
            .setVerifiedFilter(value);
      },
    );
  }

  Widget _buildContent(
    ListState<TechnicianProfileResponse, TechnicianProfileQueryFilter>
    listState,
  ) {
    if (listState.isLoading && !listState.hasData) {
      return const AppTableSkeleton(rows: 6);
    }

    if (listState.error != null && !listState.hasData) {
      return AdminListErrorState(
        message: listState.error!,
        onRetry: () => ref.read(technicianProfileListProvider.notifier).load(),
      );
    }

    if (listState.isEmpty) {
      return const AdminListEmptyState(text: 'Nema profila majstora.');
    }

    final items = listState.items ?? <TechnicianProfileResponse>[];

    return AppDataTable(
      minWidth: 900,
      columns: const [
        DataColumn2(label: Text('ID'), fixedWidth: 70),
        DataColumn2(label: Text('Majstor'), size: ColumnSize.L),
        DataColumn2(label: Text('Status'), fixedWidth: 132),
        DataColumn2(label: Text('Kontakt'), size: ColumnSize.L),
        DataColumn2(label: Text('Specijalnosti'), size: ColumnSize.L),
        DataColumn2(label: Text('Zona'), size: ColumnSize.M),
        DataColumn2(label: Text('Akcija'), fixedWidth: 120),
      ],
      rows: items.map((profile) => _buildProfileRow(profile)).toList(),
    );
  }

  DataRow _buildProfileRow(TechnicianProfileResponse profile) {
    return DataRow(
      cells: [
        DataCell(Text('#${profile.id}')),
        DataCell(Text(profile.fullName)),
        DataCell(TechnicianVerificationBadge(isVerified: profile.isVerified)),
        DataCell(
          Text(profile.userEmail, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        DataCell(
          Text(
            profile.specialties ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            profile.zone ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          TechnicianVerificationAction(
            isVerified: profile.isVerified,
            onVerify: () => _confirmVerify(profile),
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(
    ListState<TechnicianProfileResponse, TechnicianProfileQueryFilter>
    listState,
  ) {
    return AppPagination(
      currentPage: listState.filter.pageNumber,
      totalPages: listState.totalPages,
      onPrevious: listState.data!.hasPreviousPage
          ? () => ref
                .read(technicianProfileListProvider.notifier)
                .setPage(listState.filter.pageNumber - 1)
          : null,
      onNext: listState.data!.hasNextPage
          ? () => ref
                .read(technicianProfileListProvider.notifier)
                .setPage(listState.filter.pageNumber + 1)
          : null,
    );
  }

  void _confirmVerify(TechnicianProfileResponse profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verificiraj majstora'),
        content: Text('Verificirati profil majstora "${profile.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Otkazi'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(technicianProfileListProvider.notifier)
                    .verify(profile.id);
              } on ApiException catch (e) {
                if (!mounted) {
                  return;
                }

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(e.message)));
              }
            },
            child: const Text('Verificiraj'),
          ),
        ],
      ),
    );
  }
}
