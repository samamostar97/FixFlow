import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/list_state.dart';
import 'package:fixflow_desktop/providers/payment_provider.dart';
import 'package:fixflow_desktop/screens/admin/payments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A stub notifier that starts in loading state and never calls the API.
class _StubPaymentListNotifier
    extends Notifier<ListState<PaymentResponse, PaymentQueryFilter>>
    implements PaymentListNotifier {
  @override
  ListState<PaymentResponse, PaymentQueryFilter> build() {
    return ListState(filter: PaymentQueryFilter(), isLoading: true);
  }

  @override
  Future<void> load() async {}

  @override
  void setSearch(String? search) {}

  @override
  void setStatusFilter(int? status) {}

  @override
  void setPage(int page) {}
}

void main() {
  Future<void> pumpPayments(WidgetTester tester, double width) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(Size(width, 900));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentListProvider.overrideWith(_StubPaymentListNotifier.new),
        ],
        child: const MaterialApp(
          home: Scaffold(body: PaymentsScreen()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'renders payments layout without overflow on target widths',
    (tester) async {
      const widths = <double>[1536, 1366, 1200, 1024, 860];

      for (final width in widths) {
        await pumpPayments(tester, width);

        expect(find.text('Uplate'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
