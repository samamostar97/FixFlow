import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:fixflow_mobile/screens/customer/customer_dashboard_screen.dart';
import 'package:fixflow_mobile/screens/technician/technician_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const widths = <double>[320, 360, 390, 414];

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'customer dashboard renders without overflow on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 820));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: darkTheme(),
              home: CustomerDashboardScreen(onNavigateToRequests: () {}),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'technician dashboard renders without overflow on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 820));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: darkTheme(),
              home: TechnicianDashboardScreen(onNavigateToRequests: () {}),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
