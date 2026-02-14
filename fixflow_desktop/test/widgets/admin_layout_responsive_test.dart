import 'package:fixflow_desktop/widgets/shared/admin_page_scaffold.dart';
import 'package:fixflow_desktop/widgets/shared/responsive_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAtWidth(
    WidgetTester tester,
    double width,
    Widget child,
  ) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(Size(width, 640));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    await tester.pumpAndSettle();
  }

  testWidgets('compact toolbar keeps actions intrinsic width', (tester) async {
    await pumpAtWidth(
      tester,
      520,
      AdminPageScaffold(
        title: 'Test',
        subtitle: 'Responsive toolbar test',
        filters: const TextField(
          key: Key('filter_field'),
          decoration: InputDecoration(labelText: 'Pretraga'),
        ),
        actions: FilledButton(
          key: const Key('action_button'),
          onPressed: () {},
          child: const Text('Dodaj'),
        ),
        body: const SizedBox.expand(),
      ),
    );

    final actionSize = tester.getSize(find.byKey(const Key('action_button')));
    expect(actionSize.width, lessThan(220));
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide toolbar keeps action aligned to the right', (tester) async {
    await pumpAtWidth(
      tester,
      1280,
      AdminPageScaffold(
        title: 'Test',
        subtitle: 'Responsive toolbar test',
        filters: const TextField(
          key: Key('filter_field'),
          decoration: InputDecoration(labelText: 'Pretraga'),
        ),
        actions: FilledButton(
          key: const Key('action_button'),
          onPressed: () {},
          child: const Text('Dodaj'),
        ),
        body: const SizedBox.expand(),
      ),
    );

    final filterRect = tester.getRect(find.byKey(const Key('filter_field')));
    final actionRect = tester.getRect(find.byKey(const Key('action_button')));

    expect(actionRect.left, greaterThan(filterRect.right));
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact filter bar uses wrap and preserves configured widths', (
    tester,
  ) async {
    await pumpAtWidth(
      tester,
      700,
      ResponsiveFilterBar(
        compactBreakpoint: 760,
        primary: Container(key: const Key('primary'), height: 40),
        secondaryWidths: const [172, 172],
        secondary: [
          Container(key: const Key('secondary_1'), height: 40),
          Container(key: const Key('secondary_2'), height: 40),
        ],
      ),
    );

    expect(find.byType(Wrap), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('secondary_1'))).width,
      closeTo(172, 0.1),
    );
    expect(
      tester.getSize(find.byKey(const Key('secondary_2'))).width,
      closeTo(172, 0.1),
    );
  });

  testWidgets('very narrow compact filter bar expands secondary controls', (
    tester,
  ) async {
    await pumpAtWidth(
      tester,
      480,
      ResponsiveFilterBar(
        compactBreakpoint: 760,
        primary: Container(key: const Key('primary'), height: 40),
        secondaryWidths: const [172, 172],
        secondary: [
          Container(key: const Key('secondary_1'), height: 40),
          Container(key: const Key('secondary_2'), height: 40),
        ],
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('secondary_1'))).width,
      closeTo(480, 0.1),
    );
    expect(
      tester.getSize(find.byKey(const Key('secondary_2'))).width,
      closeTo(480, 0.1),
    );
  });
}
