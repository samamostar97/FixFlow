import 'package:fixflow_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FixFlowMobileApp()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}