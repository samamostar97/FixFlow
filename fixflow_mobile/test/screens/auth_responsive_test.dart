import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:fixflow_mobile/screens/auth/login_screen.dart';
import 'package:fixflow_mobile/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const widths = <double>[320, 360, 390, 414];

  for (final width in widths) {
    final currentWidth = width;
    testWidgets('login screen renders on ${currentWidth.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(currentWidth, 820));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: darkTheme(), home: const LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Dobrodosli u FixFlow'), findsOneWidget);
      expect(find.text('Prijavi se'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in widths) {
    final currentWidth = width;
    testWidgets('register screen renders on ${currentWidth.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(currentWidth, 820));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: darkTheme(), home: const RegisterScreen()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Kreirajte novi nalog'), findsOneWidget);
      expect(find.text('Registruj se'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
