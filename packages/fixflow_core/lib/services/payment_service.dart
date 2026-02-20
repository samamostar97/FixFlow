import 'dart:convert';
import 'package:fixflow_core/api/api_client.dart';
import 'package:fixflow_core/models/common/paged_result.dart';
import 'package:fixflow_core/models/filters/payment_query_filter.dart';
import 'package:fixflow_core/models/requests/confirm_payment_request.dart';
import 'package:fixflow_core/models/requests/create_checkout_request.dart';
import 'package:fixflow_core/models/responses/checkout_session_response.dart';
import 'package:fixflow_core/models/responses/payment_response.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService({required ApiClient client}) : _apiClient = client;

  Future<CheckoutResponse> createCheckout(
      CreateCheckoutRequest request) async {
    final response = await _apiClient.post(
      '/api/payments/checkout',
      body: request.toJson(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CheckoutResponse.fromJson(json);
  }

  Future<PaymentResponse> confirmPayment(
      ConfirmPaymentRequest request) async {
    final response = await _apiClient.post(
      '/api/payments/confirm',
      body: request.toJson(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PaymentResponse.fromJson(json);
  }

  Future<PaymentResponse?> getByBookingId(int bookingId) async {
    try {
      final response =
          await _apiClient.get('/api/payments/booking/$bookingId');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PaymentResponse.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<PagedResult<PaymentResponse>> getAll(
      PaymentQueryFilter filter) async {
    final response = await _apiClient.get(
      '/api/payments',
      queryParams: filter.toQueryParameters(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PagedResult.fromJson(json, PaymentResponse.fromJson);
  }
}
