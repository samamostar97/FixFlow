import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const smokeWidths = <double>[1536, 1366, 1200, 1024, 860];

Future<void> pumpGoldenHarness(
  WidgetTester tester, {
  required double width,
  required Widget child,
  double height = 900,
}) async {
  await tester.binding.setSurfaceSize(Size(width, height));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
  await tester.pumpWidget(child);
  await tester.pumpAndSettle();
}
