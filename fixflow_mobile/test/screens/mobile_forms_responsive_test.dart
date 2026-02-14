import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/screens/customer/create_repair_request_screen.dart';
import 'package:fixflow_mobile/screens/technician/create_offer_screen.dart';
import 'package:fixflow_mobile/screens/technician/widgets/technician_profile_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepairCategoryService extends RepairCategoryService {
  _FakeRepairCategoryService()
    : super(
        client: ApiClient(
          baseUrl: 'http://localhost',
          tokenStorage: TokenStorage(),
        ),
      );

  @override
  Future<List<LookupResponse>> getLookup() async {
    return [
      LookupResponse(id: 1, name: 'Klima uredjaj'),
      LookupResponse(id: 2, name: 'Ves masina'),
    ];
  }
}

void main() {
  const widths = <double>[320, 360, 390, 414];

  for (final width in widths) {
    final currentWidth = width;

    testWidgets('create offer screen renders on ${currentWidth.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(currentWidth, 840));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: darkTheme(),
            home: const CreateOfferScreen(
              repairRequestId: 1,
              categoryName: 'Ves masina',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Detalji ponude'), findsOneWidget);
      expect(find.text('Posalji ponudu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'create repair request screen renders on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 840));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              repairCategoryServiceProvider.overrideWithValue(
                _FakeRepairCategoryService(),
              ),
            ],
            child: MaterialApp(
              theme: darkTheme(),
              home: const CreateRepairRequestScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Podaci o kvaru'), findsOneWidget);
        expect(find.text('Kreiraj zahtjev'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in widths) {
    final currentWidth = width;

    testWidgets(
      'technician profile edit form renders on ${currentWidth.toInt()}px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(currentWidth, 840));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final bioController = TextEditingController();
        final specialtiesController = TextEditingController();
        final workingHoursController = TextEditingController();
        final zoneController = TextEditingController();
        addTearDown(() {
          bioController.dispose();
          specialtiesController.dispose();
          workingHoursController.dispose();
          zoneController.dispose();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: darkTheme(),
            home: Scaffold(
              body: TechnicianProfileEditForm(
                formKey: GlobalKey<FormState>(),
                bioController: bioController,
                specialtiesController: specialtiesController,
                workingHoursController: workingHoursController,
                zoneController: zoneController,
                isSubmitting: false,
                onCancel: () {},
                onSave: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Uredite profil'), findsOneWidget);
        expect(find.text('Spremi'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
