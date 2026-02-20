import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/screens/customer/create_review_screen.dart';
import 'package:fixflow_mobile/screens/customer/payment_screen.dart';
import 'package:fixflow_mobile/widgets/shared/booking_detail_sections.dart';
import 'package:fixflow_mobile/widgets/shared/booking_status_history_card.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_async_state_view.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:fixflow_mobile/widgets/shared/payment_status_badge.dart';
import 'package:fixflow_mobile/widgets/shared/review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  BookingResponse? _booking;
  ReviewResponse? _review;
  PaymentResponse? _payment;
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
      if (!mounted) return;

      ReviewResponse? review;
      if (result.jobStatus == JobStatus.completed) {
        review = await ref
            .read(reviewServiceProvider)
            .getByBookingId(widget.bookingId);
      }
      if (!mounted) return;

      final payment = await ref
          .read(paymentServiceProvider)
          .getByBookingId(widget.bookingId);
      if (!mounted) return;

      setState(() {
        _booking = result;
        _review = review;
        _payment = payment;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreateReview(BookingResponse booking) async {
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateReviewScreen(
          bookingId: booking.id,
          technicianName: booking.technicianFullName,
        ),
      ),
    );

    if (submitted == true) {
      _load();
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
          _buildPaymentSection(booking),
          const SizedBox(height: 12),
          BookingStatusHistoryCard(history: booking.statusHistory),
          if (booking.jobStatus == JobStatus.completed) ...[
            const SizedBox(height: 12),
            if (_review != null)
              ReviewCard(review: _review!)
            else
              _buildReviewButton(booking),
          ],
        ],
      ),
      emptyMessage: 'Detalji posla nisu dostupni.',
    );
  }

  void _navigateToPayment(BookingResponse booking) {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              bookingId: booking.id,
              amount: booking.totalAmount,
            ),
          ),
        )
        .then((_) => _load());
  }

  Widget _buildPaymentSection(BookingResponse booking) {
    final theme = Theme.of(context);

    if (_payment != null) {
      return MobileSectionCard(
        child: Row(
          children: [
            const Icon(LucideIcons.creditCard, size: 18),
            const SizedBox(width: 8),
            Text('Uplata', style: theme.textTheme.titleSmall),
            const Spacer(),
            PaymentStatusBadge(status: _payment!.status),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _navigateToPayment(booking),
          icon: const Icon(LucideIcons.creditCard, size: 18),
          label: const Text('Plati'),
        ),
      ),
    );
  }

  Widget _buildReviewButton(BookingResponse booking) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _navigateToCreateReview(booking),
          icon: const Icon(LucideIcons.star, size: 18),
          label: const Text('Ostavi ocjenu'),
        ),
      ),
    );
  }
}
