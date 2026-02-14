import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/customer/my_repair_requests_provider.dart';
import 'package:fixflow_mobile/screens/customer/create_repair_request_screen.dart';
import 'package:fixflow_mobile/screens/customer/repair_request_detail_screen.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_empty_state.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_paged_list_view.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyRepairRequestsScreen extends ConsumerStatefulWidget {
  const MyRepairRequestsScreen({super.key});

  @override
  ConsumerState<MyRepairRequestsScreen> createState() =>
      _MyRepairRequestsScreenState();
}

class _MyRepairRequestsScreenState
    extends ConsumerState<MyRepairRequestsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myRepairRequestsProvider.notifier).load());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myRepairRequestsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myRepairRequestsProvider);

    return MobilePageScaffold(
      title: 'Moji zahtjevi',
      subtitle: 'Pregled svih prijavljenih kvarova.',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(context),
        child: const Icon(LucideIcons.plus),
      ),
      body: MobilePagedListView<RepairRequestResponse>(
        items: state.items,
        isLoading: state.isLoading,
        hasMore: state.hasMore,
        errorMessage: state.error,
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        onRefresh: () => ref.read(myRepairRequestsProvider.notifier).load(),
        onRetry: () => ref.read(myRepairRequestsProvider.notifier).load(),
        emptyState: MobileEmptyState(
          icon: LucideIcons.wrench,
          title: 'Nemate zahtjeva za popravku.',
          action: FilledButton.icon(
            onPressed: () => _navigateToCreate(context),
            icon: const Icon(LucideIcons.plus),
            label: const Text('Kreiraj zahtjev'),
          ),
        ),
        itemBuilder: (context, request) => _RequestCard(
          request: request,
          onTap: () => _navigateToDetail(context, request),
        ),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateRepairRequestScreen()),
    );

    if (created == true) {
      ref.read(myRepairRequestsProvider.notifier).load();
    }
  }

  void _navigateToDetail(
    BuildContext context,
    RepairRequestResponse request,
  ) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RepairRequestDetailScreen(requestId: request.id),
      ),
    );

    if (changed == true) {
      ref.read(myRepairRequestsProvider.notifier).load();
    }
  }
}

class _RequestCard extends StatelessWidget {
  final RepairRequestResponse request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: MobileSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildDescription(context),
              const SizedBox(height: 8),
              _buildMetaRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(request.categoryName, style: theme.textTheme.titleMedium),
        ),
        _StatusChip(status: request.status),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      request.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          LucideIcons.mapPin,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            request.address ?? 'Bez adrese',
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        Text(
          DateFormatter.relative(request.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RepairRequestStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RepairRequestStatus.open => AppStatusColors.open,
      RepairRequestStatus.offered => AppStatusColors.pending,
      RepairRequestStatus.accepted => AppStatusColors.completed,
      RepairRequestStatus.inProgress => AppStatusColors.inProgress,
      RepairRequestStatus.completed => AppStatusColors.completed,
      RepairRequestStatus.cancelled => AppStatusColors.cancelled,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
