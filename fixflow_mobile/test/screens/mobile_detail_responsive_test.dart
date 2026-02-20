import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/screens/customer/booking_detail_screen.dart';
import 'package:fixflow_mobile/screens/customer/repair_request_detail_screen.dart';
import 'package:fixflow_mobile/screens/technician/job_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingService extends BookingService {
  final BookingResponse booking;

  _FakeBookingService(this.booking)
    : super(
        client: ApiClient(
          baseUrl: 'http://localhost',
          tokenStorage: TokenStorage(),
        ),
      );

  @override
  Future<BookingResponse> getById(int id) async => booking;
}

class _FakePaymentService extends PaymentService {
  _FakePaymentService()
    : super(
        client: ApiClient(
          baseUrl: 'http://localhost',
          tokenStorage: TokenStorage(),
        ),
      );

  @override
  Future<PaymentResponse?> getByBookingId(int bookingId) async => null;
}

class _FakeRepairRequestService extends RepairRequestService {
  final RepairRequestResponse request;

  _FakeRepairRequestService(this.request)
    : super(
        client: ApiClient(
          baseUrl: 'http://localhost',
          tokenStorage: TokenStorage(),
        ),
      );

  @override
  Future<RepairRequestResponse> getById(int id) async => request;
}

void main() {
  const widths = <double>[320, 360, 390, 414];
  final booking = _sampleBooking();
  final request = _sampleRepairRequest();

  for (final width in widths) {
    final currentWidth = width;

    testWidgets('booking detail renders on ${currentWidth.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(currentWidth, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingServiceProvider.overrideWithValue(
              _FakeBookingService(booking),
            ),
            paymentServiceProvider.overrideWithValue(
              _FakePaymentService(),
            ),
          ],
          child: MaterialApp(
            theme: darkTheme(),
            home: const BookingDetailScreen(bookingId: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Detalji posla'), findsOneWidget);
      expect(find.text('Majstor'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in widths) {
    final currentWidth = width;

    testWidgets('job detail renders on ${currentWidth.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(currentWidth, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingServiceProvider.overrideWithValue(
              _FakeBookingService(booking),
            ),
          ],
          child: MaterialApp(
            theme: darkTheme(),
            home: const JobDetailScreen(bookingId: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Detalji posla'), findsOneWidget);
      expect(find.text('Korisnik'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in widths) {
    final currentWidth = width;

    testWidgets('repair request detail renders on ${currentWidth.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(currentWidth, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repairRequestServiceProvider.overrideWithValue(
              _FakeRepairRequestService(request),
            ),
          ],
          child: MaterialApp(
            theme: darkTheme(),
            home: const RepairRequestDetailScreen(requestId: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Detalji zahtjeva'), findsOneWidget);
      expect(find.text('Otkazi zahtjev'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

BookingResponse _sampleBooking() {
  return BookingResponse(
    id: 1,
    repairRequestId: 10,
    repairRequestDescription: 'Masina curi vodu.',
    repairRequestCategoryName: 'Ves masina',
    offerId: 5,
    offerPrice: 120,
    offerEstimatedDays: 2,
    offerServiceType: ServiceType.onSite,
    customerId: 7,
    customerFirstName: 'Adnan',
    customerLastName: 'Hodzic',
    customerPhone: '061111222',
    technicianId: 9,
    technicianFirstName: 'Kemal',
    technicianLastName: 'Mehic',
    technicianPhone: '062333444',
    scheduledDate: DateTime(2026, 2, 15),
    scheduledTime: '10:00',
    jobStatus: JobStatus.repaired,
    partsDescription: 'Pumpa vode',
    partsCost: 35,
    totalAmount: 155,
    statusHistory: [
      JobStatusHistoryResponse(
        id: 1,
        bookingId: 1,
        previousStatus: JobStatus.received,
        newStatus: JobStatus.diagnostics,
        note: 'Prijem uredjaja',
        changedById: 9,
        changedByFirstName: 'Kemal',
        changedByLastName: 'Mehic',
        createdAt: DateTime(2026, 2, 14),
      ),
    ],
    createdAt: DateTime(2026, 2, 14),
  );
}

RepairRequestResponse _sampleRepairRequest() {
  return RepairRequestResponse(
    id: 1,
    categoryId: 2,
    categoryName: 'Ves masina',
    customerId: 7,
    customerFirstName: 'Adnan',
    customerLastName: 'Hodzic',
    customerEmail: 'adnan@test.com',
    customerPhone: '061111222',
    description: 'Masina pravi buku i curi voda.',
    preferenceType: PreferenceType.onSite,
    address: 'Mostar, BiH',
    status: RepairRequestStatus.open,
    images: const [],
    createdAt: DateTime(2026, 2, 14),
  );
}
