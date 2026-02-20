import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:fixflow_mobile/widgets/shared/image_picker_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  const widths = <double>[320, 360, 390, 414];

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'image picker empty state renders on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 840));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            theme: darkTheme(),
            home: Scaffold(
              body: ImagePickerSection(
                pickedFiles: const <XFile>[],
                onPickedChanged: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Slike'), findsOneWidget);
        expect(find.text('(0/5)'), findsOneWidget);
        expect(find.text('Dodaj'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'image picker with existing images renders on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 840));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final images = [
          RequestImageResponse(
            id: 1,
            imagePath: '/uploads/test1.jpg',
            originalFileName: 'test1.jpg',
            fileSize: 1024,
          ),
          RequestImageResponse(
            id: 2,
            imagePath: '/uploads/test2.jpg',
            originalFileName: 'test2.jpg',
            fileSize: 2048,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: darkTheme(),
            home: Scaffold(
              body: ImagePickerSection(
                pickedFiles: const <XFile>[],
                existingImages: images,
                baseUrl: 'http://localhost',
                onPickedChanged: (_) {},
                onExistingRemoved: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('(2/5)'), findsOneWidget);
        expect(find.byIcon(LucideIcons.x), findsNWidgets(2));
        expect(find.text('Dodaj'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('add button hidden when max images reached', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final images = List.generate(
      5,
      (i) => RequestImageResponse(
        id: i + 1,
        imagePath: '/uploads/test$i.jpg',
        originalFileName: 'test$i.jpg',
        fileSize: 1024,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme(),
        home: Scaffold(
          body: ImagePickerSection(
            pickedFiles: const <XFile>[],
            existingImages: images,
            baseUrl: 'http://localhost',
            onPickedChanged: (_) {},
            onExistingRemoved: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('(5/5)'), findsOneWidget);
    expect(find.text('Dodaj'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
