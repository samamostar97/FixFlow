import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/widgets/shared/booking_detail_sections.dart';
import 'package:fixflow_mobile/widgets/shared/booking_status_history_card.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_async_state_view.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  BookingResponse? _booking;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(bookingServiceProvider)
          .getById(widget.bookingId);
      if (!mounted) {
        return;
      }
      setState(() {
        _booking = result;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobilePageScaffold(
      title: 'Detalji posla',
      onRefresh: _load,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return MobileAsyncStateView<BookingResponse>(
      isLoading: _isLoading,
      error: _error,
      data: _booking,
      onRetry: _load,
      builder: (booking) => ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        children: [
          BookingHeaderCard(booking: booking),
          const SizedBox(height: 12),
          BookingPersonInfoCard(
            title: 'Majstor',
            fullName: booking.technicianFullName,
            phone: booking.technicianPhone,
            serviceType: booking.offerServiceType.displayName,
            scheduledDate: booking.scheduledDate,
            scheduledLabel: 'Zakazan',
          ),
          const SizedBox(height: 12),
          BookingRequestInfoCard(description: booking.repairRequestDescription),
          if (booking.partsDescription != null) ...[
            const SizedBox(height: 12),
            BookingPartsInfoCard(
              partsDescription: booking.partsDescription!,
              partsCost: booking.partsCost,
            ),
          ],
          const SizedBox(height: 12),
          BookingPriceBreakdownCard(
            offerPrice: booking.offerPrice,
            partsCost: booking.partsCost,
            totalAmount: booking.totalAmount,
          ),
          const SizedBox(height: 12),
          BookingStatusHistoryCard(history: booking.statusHistory),
        ],
      ),
      emptyMessage: 'Detalji posla nisu dostupni.',
    );
  }
}
