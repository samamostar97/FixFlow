import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/screens/technician/widgets/job_detail_actions.dart';
import 'package:fixflow_mobile/widgets/shared/booking_detail_sections.dart';
import 'package:fixflow_mobile/widgets/shared/booking_status_history_card.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_async_state_view.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const JobDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  BookingResponse? _booking;
  bool _isLoading = true;
  String? _error;
  bool _changed = false;

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

  Future<void> _startStatusUpdate(JobStatus nextStatus) async {
    final booking = _booking!;
    final note = await showStatusUpdateBottomSheet(
      context: context,
      currentStatus: booking.jobStatus,
      nextStatus: nextStatus,
    );
    if (note == null) {
      return;
    }

    try {
      await ref
          .read(bookingServiceProvider)
          .updateJobStatus(
            booking.id,
            UpdateJobStatusRequest(
              newStatus: nextStatus.index,
              note: note.isEmpty ? null : note,
            ),
          );
      _changed = true;
      await _load();
      if (!mounted) {
        return;
      }
      MobileSnackbar.success(context, 'Status je uspjesno azuriran.');
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      MobileSnackbar.error(context, e.message);
    }
  }

  Future<void> _startAddPart() async {
    final booking = _booking!;
    final payload = await showAddPartsBottomSheet(context);
    if (payload == null) {
      return;
    }

    try {
      await ref
          .read(bookingServiceProvider)
          .updateParts(
            booking.id,
            UpdateBookingPartsRequest(
              partsDescription: payload.description,
              partsCost: payload.cost,
            ),
          );
      _changed = true;
      await _load();
      if (!mounted) {
        return;
      }
      MobileSnackbar.success(context, 'Dio je uspjesno dodat.');
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      MobileSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobilePageScaffold(
      title: 'Detalji posla',
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(_changed),
        icon: const Icon(LucideIcons.arrowLeft),
      ),
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
            title: 'Korisnik',
            fullName: booking.customerFullName,
            phone: booking.customerPhone,
            serviceType: booking.offerServiceType.displayName,
            scheduledDate: booking.scheduledDate,
            scheduledLabel: 'Zakazano',
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
          JobDetailActionsCard(
            booking: booking,
            onUpdateStatus: _startStatusUpdate,
            onAddPart: _startAddPart,
          ),
          const SizedBox(height: 12),
          BookingStatusHistoryCard(history: booking.statusHistory),
        ],
      ),
      emptyMessage: 'Detalji posla nisu dostupni.',
    );
  }
}
