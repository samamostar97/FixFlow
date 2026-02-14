import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/customer/my_bookings_provider.dart';
import 'package:fixflow_mobile/screens/customer/booking_detail_screen.dart';
import 'package:fixflow_mobile/widgets/shared/booking_card.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_empty_state.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_paged_list_view.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myBookingsProvider.notifier).load());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myBookingsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myBookingsProvider);

    return MobilePageScaffold(
      title: 'Poslovi',
      subtitle: 'Pracenje statusa servisa.',
      body: MobilePagedListView<BookingResponse>(
        items: state.items,
        isLoading: state.isLoading,
        hasMore: state.hasMore,
        errorMessage: state.error,
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        onRefresh: () => ref.read(myBookingsProvider.notifier).load(),
        onRetry: () => ref.read(myBookingsProvider.notifier).load(),
        emptyState: const MobileEmptyState(
          icon: LucideIcons.briefcase,
          title: 'Nemate aktivnih poslova.',
        ),
        itemBuilder: (context, booking) => BookingCard(
          booking: booking,
          onTap: () => _navigateToDetail(booking),
        ),
      ),
    );
  }

  void _navigateToDetail(BookingResponse booking) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(bookingId: booking.id),
      ),
    );

    if (changed == true) {
      ref.read(myBookingsProvider.notifier).load();
    }
  }
}
