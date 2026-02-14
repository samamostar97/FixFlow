import 'package:data_table_2/data_table_2.dart';
import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:fixflow_desktop/providers/repair_category_provider.dart';
import 'package:fixflow_desktop/screens/admin/widgets/repair_category_dialogs.dart';
import 'package:fixflow_desktop/constants/app_density.dart';
import 'package:fixflow_desktop/widgets/shared/admin_list_states.dart';
import 'package:fixflow_desktop/widgets/shared/admin_page_scaffold.dart';
import 'package:fixflow_desktop/widgets/shared/app_data_table.dart';
import 'package:fixflow_desktop/widgets/shared/app_pagination.dart';
import 'package:fixflow_desktop/widgets/shared/loading_skeleton.dart';
import 'package:fixflow_desktop/widgets/shared/responsive_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RepairCategoriesScreen extends ConsumerStatefulWidget {
  const RepairCategoriesScreen({super.key});

  @override
  ConsumerState<RepairCategoriesScreen> createState() =>
      _RepairCategoriesScreenState();
}

class _RepairCategoriesScreenState
    extends ConsumerState<RepairCategoriesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(repairCategoryListProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(repairCategoryListProvider);

    return AdminPageScaffold(
      title: 'Kategorije popravki',
      subtitle: 'Upravljanje lookup listom kategorija.',
      filters: _buildSearchBar(),
      actions: _buildCreateButton(),
      body: _buildContent(listState),
      footer: listState.totalPages > 1 ? _buildPagination(listState) : null,
    );
  }

  Widget _buildSearchBar() {
    return ResponsiveFilterBar(
      compactBreakpoint: 760,
      primary: _buildSearchField(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        hintText: 'Pretrazi po nazivu kategorije...',
        prefixIcon: Icon(LucideIcons.search),
      ),
      onChanged: (value) {
        ref
            .read(repairCategoryListProvider.notifier)
            .setSearch(value.isEmpty ? null : value);
      },
    );
  }

  Widget _buildCreateButton() {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: AppDensity.inputHeight + 8,
      child: FilledButton.icon(
        onPressed: _openCreateDialog,
        style: FilledButton.styleFrom(
          minimumSize: const Size(210, AppDensity.inputHeight + 8),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
          ),
        ),
        icon: const Icon(LucideIcons.plus, size: 16),
        label: const Text('Dodaj kategoriju'),
      ),
    );
  }

  Widget _buildContent(
    ListState<RepairCategoryResponse, RepairCategoryQueryFilter> listState,
  ) {
    if (listState.isLoading && !listState.hasData) {
      return const AppTableSkeleton(rows: 6);
    }

    if (listState.error != null && !listState.hasData) {
      return AdminListErrorState(
        message: listState.error!,
        onRetry: () => ref.read(repairCategoryListProvider.notifier).load(),
      );
    }

    if (listState.isEmpty) {
      return const AdminListEmptyState(text: 'Nema kategorija.');
    }

    final items = listState.items ?? <RepairCategoryResponse>[];

    return AppDataTable(
      minWidth: 760,
      columns: const [
        DataColumn2(label: Text('ID'), fixedWidth: 70),
        DataColumn2(label: Text('Naziv'), size: ColumnSize.L),
        DataColumn2(label: Text('Kreirano'), fixedWidth: 132),
        DataColumn2(label: Text('Akcije'), fixedWidth: 124),
      ],
      rows: items.map((category) => _buildRow(category)).toList(),
    );
  }

  DataRow _buildRow(RepairCategoryResponse category) {
    return DataRow(
      cells: [
        DataCell(Text('#${category.id}')),
        DataCell(
          Text(category.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        DataCell(Text(DateFormatter.format(category.createdAt))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tableActionButton(
                icon: LucideIcons.pencil,
                tooltip: 'Uredi kategoriju',
                onPressed: () => _openEditDialog(category),
              ),
              const SizedBox(width: 8),
              _tableActionButton(
                icon: LucideIcons.trash2,
                tooltip: 'Obrisi kategoriju',
                onPressed: () => _openDeleteDialog(category),
                destructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool destructive = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final foreground = destructive ? cs.error : cs.onSurfaceVariant;
    final border = destructive
        ? cs.error.withValues(alpha: 0.45)
        : cs.outlineVariant;
    final background = destructive
        ? cs.error.withValues(alpha: 0.14)
        : cs.surfaceContainerLow.withValues(alpha: 0.45);

    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: background,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 16, color: foreground),
      ),
    );
  }

  Widget _buildPagination(
    ListState<RepairCategoryResponse, RepairCategoryQueryFilter> listState,
  ) {
    return AppPagination(
      currentPage: listState.filter.pageNumber,
      totalPages: listState.totalPages,
      onPrevious: listState.data!.hasPreviousPage
          ? () => ref
                .read(repairCategoryListProvider.notifier)
                .setPage(listState.filter.pageNumber - 1)
          : null,
      onNext: listState.data!.hasNextPage
          ? () => ref
                .read(repairCategoryListProvider.notifier)
                .setPage(listState.filter.pageNumber + 1)
          : null,
    );
  }

  void _openCreateDialog() {
    showRepairCategoryFormDialog(
      context: context,
      onCreate: (name) => ref
          .read(repairCategoryListProvider.notifier)
          .create(CreateRepairCategoryRequest(name: name)),
      onUpdate: (id, name) => ref
          .read(repairCategoryListProvider.notifier)
          .update(id, UpdateRepairCategoryRequest(name: name)),
    );
  }

  void _openEditDialog(RepairCategoryResponse category) {
    showRepairCategoryFormDialog(
      context: context,
      category: category,
      onCreate: (name) => ref
          .read(repairCategoryListProvider.notifier)
          .create(CreateRepairCategoryRequest(name: name)),
      onUpdate: (id, name) => ref
          .read(repairCategoryListProvider.notifier)
          .update(id, UpdateRepairCategoryRequest(name: name)),
    );
  }

  void _openDeleteDialog(RepairCategoryResponse category) {
    showRepairCategoryDeleteDialog(
      context: context,
      category: category,
      onDelete: (id) =>
          ref.read(repairCategoryListProvider.notifier).delete(id),
    );
  }
}
