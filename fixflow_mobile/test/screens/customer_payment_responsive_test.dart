import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:fixflow_mobile/screens/customer/payment_screen.dart';
import 'package:fixflow_mobile/widgets/shared/payment_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const widths = <double>[320, 360, 390, 414];

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'payment screen renders on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 840));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: darkTheme(),
              home: const PaymentScreen(bookingId: 1, amount: 80.0),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Placanje'), findsOneWidget);
        expect(find.text('Pregled uplate'), findsOneWidget);
        expect(find.text('#1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('payment status badge renders all statuses', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final status in PaymentStatus.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme(),
          home: Scaffold(
            body: Center(child: PaymentStatusBadge(status: status)),
          ),
        ),
      );

      expect(find.text(status.displayName), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
