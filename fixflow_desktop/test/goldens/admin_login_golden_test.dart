import 'package:fixflow_desktop/constants/app_theme.dart';
import 'package:fixflow_desktop/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_test_helpers.dart';

void main() {
  Widget buildHarness() {
    return ProviderScope(
      child: MaterialApp(theme: darkTheme(), home: const LoginScreen()),
    );
  }

  for (final width in smokeWidths) {
    final widthLabel = width.toInt();

    testWidgets('login golden $widthLabel', (tester) async {
      await pumpGoldenHarness(tester, width: width, child: buildHarness());

      await expectLater(
        find.byType(Scaffold).first,
        matchesGoldenFile('baselines/login_$widthLabel.png'),
      );
    });
  }
}
