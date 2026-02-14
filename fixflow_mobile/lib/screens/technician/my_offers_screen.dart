import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/providers/technician/my_offers_provider.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_empty_state.dart';
import 'package:fixflow_mobile/widgets/shared/offer_card.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_paged_list_view.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyOffersScreen extends ConsumerStatefulWidget {
  const MyOffersScreen({super.key});

  @override
  ConsumerState<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends ConsumerState<MyOffersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myOffersProvider.notifier).load());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myOffersProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _withdraw(OfferResponse offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Povuci ponudu'),
        content: const Text('Da li ste sigurni da zelite povuci ovu ponudu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ne'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Da, povuci'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(offerServiceProvider).withdraw(offer.id);
      if (!mounted) {
        return;
      }
      MobileSnackbar.success(context, 'Ponuda je povucena.');
      ref.read(myOffersProvider.notifier).load();
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      MobileSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myOffersProvider);
    return MobilePagedListView<OfferResponse>(
      items: state.items,
      isLoading: state.isLoading,
      hasMore: state.hasMore,
      errorMessage: state.error,
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      onRefresh: () => ref.read(myOffersProvider.notifier).load(),
      onRetry: () => ref.read(myOffersProvider.notifier).load(),
      emptyState: const MobileEmptyState(
        icon: LucideIcons.messageSquare,
        title: 'Nemate ponuda.',
      ),
      itemBuilder: (context, offer) => OfferCard(
        offer: offer,
        onWithdraw: offer.status == OfferStatus.pending
            ? () => _withdraw(offer)
            : null,
      ),
    );
  }
}
