import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:fixflow_mobile/providers/auth_provider.dart';
import 'package:fixflow_mobile/screens/customer/customer_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

UserResponse _fakeUser() => UserResponse(
      id: 1,
      firstName: 'Amir',
      lastName: 'Hodzic',
      email: 'amir@test.com',
      phone: '+38761123456',
      role: UserRole.customer,
      createdAt: DateTime(2025, 1, 15),
    );

class _SeededAuthNotifier extends AuthNotifier {
  final UserResponse _seed;
  _SeededAuthNotifier(this._seed);

  @override
  AuthState build() => AuthState(user: _seed);
}

void main() {
  const widths = <double>[320, 360, 390, 414];

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'customer profile display renders on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 840));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(() => _SeededAuthNotifier(_fakeUser())),
            ],
            child: MaterialApp(
              theme: darkTheme(),
              home: const CustomerProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Moj profil'), findsOneWidget);
        expect(find.text('Amir Hodzic'), findsOneWidget);
        expect(find.text('amir@test.com'), findsOneWidget);
        expect(find.text('+38761123456'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'customer profile edit mode renders on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 840));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(() => _SeededAuthNotifier(_fakeUser())),
            ],
            child: MaterialApp(
              theme: darkTheme(),
              home: const CustomerProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the edit button (pencil icon)
        await tester.tap(find.byIcon(LucideIcons.pencil));
        await tester.pumpAndSettle();

        expect(find.text('Uredite profil'), findsOneWidget);
        expect(find.text('Spremi'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
