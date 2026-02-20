import 'dart:convert';

import 'package:fixflow_core/api/api_client.dart';
import 'package:fixflow_core/models/common/paged_result.dart';
import 'package:fixflow_core/models/filters/review_query_filter.dart';
import 'package:fixflow_core/models/requests/create_review_request.dart';
import 'package:fixflow_core/models/responses/review_response.dart';

class ReviewService {
  final ApiClient _apiClient;

  ReviewService({required ApiClient client}) : _apiClient = client;

  Future<ReviewResponse> create(CreateReviewRequest request) async {
    final response = await _apiClient.post(
      '/api/reviews',
      body: request.toJson(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ReviewResponse.fromJson(json);
  }

  Future<ReviewResponse?> getByBookingId(int bookingId) async {
    try {
      final response = await _apiClient.get('/api/reviews/booking/$bookingId');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ReviewResponse.fromJson(json);
    } on Exception {
      return null;
    }
  }

  Future<PagedResult<ReviewResponse>> getForTechnician(
      int technicianId, ReviewQueryFilter filter) async {
    final response = await _apiClient.get(
      '/api/reviews/technician/$technicianId',
      queryParams: filter.toQueryParameters(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PagedResult.fromJson(json, ReviewResponse.fromJson);
  }

  Future<PagedResult<ReviewResponse>> getAll(ReviewQueryFilter filter) async {
    final response = await _apiClient.get(
      '/api/reviews',
      queryParams: filter.toQueryParameters(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PagedResult.fromJson(json, ReviewResponse.fromJson);
  }
}
