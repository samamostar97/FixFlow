import 'package:fixflow_mobile/widgets/shared/loading_skeleton.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_async_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrapTestApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('renders loading state', (tester) async {
    await tester.pumpWidget(
      wrapTestApp(
        MobileAsyncStateView<int>(
          isLoading: true,
          error: null,
          data: null,
          onRetry: () async {},
          builder: (_) => const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.byType(AppListSkeleton), findsOneWidget);
  });

  testWidgets('renders error state', (tester) async {
    await tester.pumpWidget(
      wrapTestApp(
        MobileAsyncStateView<int>(
          isLoading: false,
          error: 'Greška.',
          data: null,
          onRetry: () async {},
          builder: (_) => const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Greška.'), findsOneWidget);
    expect(find.text('Pokusaj ponovo'), findsOneWidget);
  });

  testWidgets('renders empty-message state when data missing', (tester) async {
    await tester.pumpWidget(
      wrapTestApp(
        MobileAsyncStateView<int>(
          isLoading: false,
          error: null,
          data: null,
          onRetry: () async {},
          emptyMessage: 'Nema podataka.',
          builder: (_) => const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Nema podataka.'), findsOneWidget);
  });

  testWidgets('renders data widget', (tester) async {
    await tester.pumpWidget(
      wrapTestApp(
        MobileAsyncStateView<int>(
          isLoading: false,
          error: null,
          data: 42,
          onRetry: () async {},
          builder: (value) => Text('Vrijednost: $value'),
        ),
      ),
    );

    expect(find.text('Vrijednost: 42'), findsOneWidget);
  });
}
