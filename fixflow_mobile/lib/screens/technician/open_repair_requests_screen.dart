import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/technician/open_repair_requests_provider.dart';
import 'package:fixflow_mobile/screens/technician/create_offer_screen.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_empty_state.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_paged_list_view.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OpenRepairRequestsScreen extends ConsumerStatefulWidget {
  const OpenRepairRequestsScreen({super.key});

  @override
  ConsumerState<OpenRepairRequestsScreen> createState() =>
      _OpenRepairRequestsScreenState();
}

class _OpenRepairRequestsScreenState
    extends ConsumerState<OpenRepairRequestsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(openRepairRequestsProvider.notifier).load(),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(openRepairRequestsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openCreateOffer(RepairRequestResponse request) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateOfferScreen(
          repairRequestId: request.id,
          categoryName: request.categoryName,
        ),
      ),
    );

    if (result == true) {
      ref.read(openRepairRequestsProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(openRepairRequestsProvider);
    return MobilePagedListView<RepairRequestResponse>(
      items: state.items,
      isLoading: state.isLoading,
      hasMore: state.hasMore,
      errorMessage: state.error,
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      onRefresh: () => ref.read(openRepairRequestsProvider.notifier).load(),
      onRetry: () => ref.read(openRepairRequestsProvider.notifier).load(),
      emptyState: const MobileEmptyState(
        icon: LucideIcons.search,
        title: 'Nema otvorenih zahtjeva.',
      ),
      itemBuilder: (context, request) => _OpenRequestCard(
        request: request,
        onSendOffer: () => _openCreateOffer(request),
      ),
    );
  }
}

class _OpenRequestCard extends StatelessWidget {
  final RepairRequestResponse request;
  final VoidCallback onSendOffer;

  const _OpenRequestCard({required this.request, required this.onSendOffer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MobileSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildDescription(context),
            const SizedBox(height: 8),
            _buildMeta(context),
            const SizedBox(height: 12),
            _buildAction(),
          ],
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            request.preferenceType.displayName,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      request.description,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMeta(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _metaWithIcon(
          context: context,
          icon: LucideIcons.user,
          text: request.customerFullName,
        ),
        if (request.address != null)
          _metaWithIcon(
            context: context,
            icon: LucideIcons.mapPin,
            text: request.address!,
          ),
        Text(
          DateFormatter.relative(request.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _metaWithIcon({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildAction() {
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.tonal(
        onPressed: onSendOffer,
        child: const Text('Posalji ponudu'),
      ),
    );
  }
}
