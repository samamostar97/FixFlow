import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:fixflow_mobile/screens/customer/create_review_screen.dart';
import 'package:fixflow_mobile/widgets/shared/review_card.dart';
import 'package:fixflow_mobile/widgets/shared/star_rating_input.dart';
import 'package:fixflow_core/fixflow_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const widths = <double>[320, 360, 390, 414];

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'create review screen renders on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 840));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: darkTheme(),
              home: const CreateReviewScreen(
                bookingId: 1,
                technicianName: 'Kemal Mehic',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Recenzija'), findsOneWidget);
        expect(find.text('Posalji ocjenu'), findsOneWidget);
        expect(find.byType(StarRatingInput), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'review card renders on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 840));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            theme: darkTheme(),
            home: Scaffold(
              body: ReviewCard(
                review: ReviewResponse(
                  id: 1,
                  bookingId: 1,
                  customerId: 1,
                  customerFirstName: 'Amir',
                  customerLastName: 'Hodzic',
                  technicianId: 2,
                  technicianFirstName: 'Kemal',
                  technicianLastName: 'Mehic',
                  rating: 5,
                  comment: 'Brza i kvalitetna popravka, preporucujem!',
                  createdAt: DateTime.now(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Vasa ocjena'), findsOneWidget);
        expect(find.text('Brza i kvalitetna popravka, preporucujem!'),
            findsOneWidget);
        expect(find.byType(StarRatingDisplay), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
