import 'dart:convert';

import 'package:fixflow_core/api/api_client.dart';
import 'package:fixflow_core/models/common/paged_result.dart';
import 'package:fixflow_core/models/filters/booking_query_filter.dart';
import 'package:fixflow_core/models/requests/update_booking_parts_request.dart';
import 'package:fixflow_core/models/requests/update_job_status_request.dart';
import 'package:fixflow_core/models/responses/booking_response.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService({required ApiClient client}) : _apiClient = client;

  Future<PagedResult<BookingResponse>> getAll(BookingQueryFilter filter) async {
    final response = await _apiClient.get(
      '/api/bookings',
      queryParams: filter.toQueryParameters(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PagedResult.fromJson(json, BookingResponse.fromJson);
  }

  Future<BookingResponse> getById(int id) async {
    final response = await _apiClient.get('/api/bookings/$id');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return BookingResponse.fromJson(json);
  }

  Future<PagedResult<BookingResponse>> getMyBookings(
      BookingQueryFilter filter) async {
    final response = await _apiClient.get(
      '/api/bookings/my',
      queryParams: filter.toQueryParameters(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PagedResult.fromJson(json, BookingResponse.fromJson);
  }

  Future<BookingResponse> updateJobStatus(
      int bookingId, UpdateJobStatusRequest request) async {
    final response = await _apiClient.patch(
      '/api/bookings/$bookingId/status',
      body: request.toJson(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return BookingResponse.fromJson(json);
  }

  Future<BookingResponse> updateParts(
      int bookingId, UpdateBookingPartsRequest request) async {
    final response = await _apiClient.patch(
      '/api/bookings/$bookingId/parts',
      body: request.toJson(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return BookingResponse.fromJson(json);
  }
}
