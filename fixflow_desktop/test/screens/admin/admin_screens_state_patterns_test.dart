import 'package:fixflow_desktop/widgets/shared/admin_page_scaffold.dart';
import 'package:fixflow_desktop/widgets/shared/loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum _ScreenState { loading, error, empty, data }

class _StatePatternHarness extends StatelessWidget {
  final _ScreenState state;

  const _StatePatternHarness({required this.state});

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Test ekran',
      subtitle: 'State pattern test',
      body: switch (state) {
        _ScreenState.loading => const AppTableSkeleton(),
        _ScreenState.error => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Greska pri ucitavanju.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () {}, child: const Text('Pokusaj ponovo')),
            ],
          ),
        ),
        _ScreenState.empty => const Center(child: Text('Nema podataka.')),
        _ScreenState.data => ListView(
          children: const [
            ListTile(
              leading: Icon(LucideIcons.check),
              title: Text('Podatak 1'),
            ),
          ],
        ),
      },
    );
  }
}

void main() {
  Future<void> pumpHarness(WidgetTester tester, _ScreenState state) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: _StatePatternHarness(state: state)),
      ),
    );
    await tester.pump();
  }

  testWidgets('loading state is visible', (tester) async {
    await pumpHarness(tester, _ScreenState.loading);

    expect(find.byType(AppTableSkeleton), findsOneWidget);
  });

  testWidgets('error state is visible', (tester) async {
    await pumpHarness(tester, _ScreenState.error);

    expect(find.text('Greska pri ucitavanju.'), findsOneWidget);
    expect(find.text('Pokusaj ponovo'), findsOneWidget);
  });

  testWidgets('empty state is visible', (tester) async {
    await pumpHarness(tester, _ScreenState.empty);

    expect(find.text('Nema podataka.'), findsOneWidget);
  });

  testWidgets('data state is visible', (tester) async {
    await pumpHarness(tester, _ScreenState.data);

    expect(find.text('Podatak 1'), findsOneWidget);
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
  });
}
