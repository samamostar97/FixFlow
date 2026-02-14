import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_top_tabs_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const widths = <double>[320, 360, 390, 414];

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'mobile top tabs render and switch on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 780));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            theme: darkTheme(),
            home: const Scaffold(
              body: MobileTopTabsSection(
                tabs: [
                  Tab(text: 'Prvi'),
                  Tab(text: 'Drugi'),
                ],
                children: [
                  Center(child: Text('Prvi sadrzaj')),
                  Center(child: Text('Drugi sadrzaj')),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Prvi sadrzaj'), findsOneWidget);

        await tester.tap(find.text('Drugi'));
        await tester.pumpAndSettle();
        expect(find.text('Drugi sadrzaj'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );
  }
}
