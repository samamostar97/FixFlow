import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:fixflow_mobile/widgets/shared/payment_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentResponse? _payment;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    setState(() => _isLoading = true);
    try {
      final payment = await ref
          .read(paymentServiceProvider)
          .getByBookingId(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startPayment() async {
    setState(() => _isProcessing = true);
    try {
      final checkout = await ref.read(paymentServiceProvider).createCheckout(
            CreateCheckoutRequest(bookingId: widget.bookingId),
          );
      if (!mounted) return;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: checkout.clientSecret,
          merchantDisplayName: 'FixFlow',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      if (!mounted) return;

      final confirmed =
          await ref.read(paymentServiceProvider).confirmPayment(
                ConfirmPaymentRequest(
                  bookingId: widget.bookingId,
                  paymentIntentId: checkout.paymentIntentId,
                ),
              );
      if (!mounted) return;

      setState(() => _payment = confirmed);
      MobileSnackbar.success(context, 'Uplata uspjesna!');
    } on StripeException catch (e) {
      if (!mounted) return;
      if (e.error.code != FailureCode.Canceled) {
        MobileSnackbar.error(
          context,
          e.error.localizedMessage ?? 'Greska prilikom placanja.',
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      MobileSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MobilePageScaffold(
      title: 'Placanje',
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => Navigator.of(context).pop(),
      ),
      onRefresh: _loadPayment,
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        children: [
          _buildSummaryCard(theme),
          if (_shouldShowPayButton) ...[
            const SizedBox(height: 16),
            _buildPayButton(),
          ],
        ],
      ),
    );
  }

  bool get _shouldShowPayButton =>
      !_isLoading &&
      (_payment == null || _payment!.status == PaymentStatus.failed);

  Widget _buildSummaryCard(ThemeData theme) {
    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pregled uplate', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          _buildInfoRow(theme, 'Posao', '#${widget.bookingId}'),
          const SizedBox(height: 8),
          _buildInfoRow(
            theme,
            'Iznos',
            CurrencyFormatter.format(widget.amount),
          ),
          if (_payment != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Status',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                PaymentStatusBadge(status: _payment!.status),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FilledButton.icon(
        onPressed: _isProcessing ? null : _startPayment,
        icon: _isProcessing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.creditCard),
        label: const Text('Plati'),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
