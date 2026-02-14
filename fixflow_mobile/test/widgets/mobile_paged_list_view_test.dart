import 'package:fixflow_mobile/widgets/shared/loading_skeleton.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_empty_state.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_paged_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('shows skeleton during initial loading', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        MobilePagedListView<int>(
          items: const [],
          isLoading: true,
          hasMore: false,
          onRetry: () {},
          emptyState: const SizedBox.shrink(),
          itemBuilder: (_, item) => Text('$item'),
        ),
      ),
    );

    expect(find.byType(AppListSkeleton), findsOneWidget);
  });

  testWidgets('shows error state when loading fails and no items', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        MobilePagedListView<int>(
          items: const [],
          isLoading: false,
          hasMore: false,
          errorMessage: 'Greška pri učitavanju.',
          onRetry: () {},
          emptyState: const SizedBox.shrink(),
          itemBuilder: (_, item) => Text('$item'),
        ),
      ),
    );

    expect(find.text('Greška pri učitavanju.'), findsOneWidget);
    expect(find.text('Pokusaj ponovo'), findsOneWidget);
  });

  testWidgets('shows empty state when there is no data', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        MobilePagedListView<int>(
          items: const [],
          isLoading: false,
          hasMore: false,
          onRetry: () {},
          emptyState: const MobileEmptyState(
            icon: LucideIcons.search,
            title: 'Nema podataka.',
          ),
          itemBuilder: (_, item) => Text('$item'),
        ),
      ),
    );

    expect(find.text('Nema podataka.'), findsOneWidget);
  });

  testWidgets('shows list items and load-more indicator', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        MobilePagedListView<int>(
          items: const [1, 2],
          isLoading: false,
          hasMore: true,
          onRetry: () {},
          emptyState: const SizedBox.shrink(),
          itemBuilder: (_, item) => ListTile(title: Text('Stavka $item')),
        ),
      ),
    );

    expect(find.text('Stavka 1'), findsOneWidget);
    expect(find.text('Stavka 2'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
