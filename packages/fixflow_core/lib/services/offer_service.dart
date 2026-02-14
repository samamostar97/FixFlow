import 'dart:convert';

import 'package:fixflow_core/api/api_client.dart';
import 'package:fixflow_core/models/common/paged_result.dart';
import 'package:fixflow_core/models/filters/offer_query_filter.dart';
import 'package:fixflow_core/models/requests/create_offer_request.dart';
import 'package:fixflow_core/models/requests/update_offer_request.dart';
import 'package:fixflow_core/models/responses/offer_response.dart';
import 'package:fixflow_core/services/crud_service.dart';

class OfferService extends CrudService<OfferResponse, CreateOfferRequest,
    UpdateOfferRequest, OfferQueryFilter> {
  final ApiClient _apiClient;

  OfferService({required super.client})
      : _apiClient = client,
        super(
          basePath: '/api/offers',
          fromJson: OfferResponse.fromJson,
        );

  Future<PagedResult<OfferResponse>> getMyOffers(
      OfferQueryFilter filter) async {
    final response = await _apiClient.get(
      '/api/offers/my',
      queryParams: filter.toQueryParameters(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PagedResult.fromJson(json, OfferResponse.fromJson);
  }

  Future<List<OfferResponse>> getOffersForRequest(int requestId) async {
    final response = await _apiClient.get(
      '/api/repair-requests/$requestId/offers',
    );
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => OfferResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OfferResponse> accept(int offerId) async {
    final response = await _apiClient.post('/api/offers/$offerId/accept');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OfferResponse.fromJson(json);
  }

  Future<OfferResponse> withdraw(int offerId) async {
    final response = await _apiClient.post('/api/offers/$offerId/withdraw');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OfferResponse.fromJson(json);
  }
}
