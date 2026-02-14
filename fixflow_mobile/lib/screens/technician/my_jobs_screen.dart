import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/technician/my_jobs_provider.dart';
import 'package:fixflow_mobile/screens/technician/job_detail_screen.dart';
import 'package:fixflow_mobile/widgets/shared/booking_card.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_empty_state.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_paged_list_view.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myJobsProvider.notifier).load());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myJobsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myJobsProvider);

    return MobilePageScaffold(
      title: 'Poslovi',
      subtitle: 'Aktivni i zavrseni servisni poslovi.',
      body: MobilePagedListView<BookingResponse>(
        items: state.items,
        isLoading: state.isLoading,
        hasMore: state.hasMore,
        errorMessage: state.error,
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        onRefresh: () => ref.read(myJobsProvider.notifier).load(),
        onRetry: () => ref.read(myJobsProvider.notifier).load(),
        emptyState: const MobileEmptyState(
          icon: LucideIcons.briefcase,
          title: 'Nemate aktivnih poslova.',
        ),
        itemBuilder: (context, booking) => BookingCard(
          booking: booking,
          showCustomerName: true,
          onTap: () => _navigateToDetail(booking),
        ),
      ),
    );
  }

  void _navigateToDetail(BookingResponse booking) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => JobDetailScreen(bookingId: booking.id)),
    );

    if (changed == true) {
      ref.read(myJobsProvider.notifier).load();
    }
  }
}
