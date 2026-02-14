import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fixflow_core/api/api_client.dart';
import 'package:fixflow_core/models/common/paged_result.dart';
import 'package:fixflow_core/models/filters/repair_request_query_filter.dart';
import 'package:fixflow_core/models/requests/create_repair_request_request.dart';
import 'package:fixflow_core/models/requests/update_repair_request_request.dart';
import 'package:fixflow_core/models/responses/repair_request_response.dart';
import 'package:fixflow_core/models/responses/request_image_response.dart';
import 'package:fixflow_core/services/crud_service.dart';

class RepairRequestService extends CrudService<RepairRequestResponse,
    CreateRepairRequestRequest, UpdateRepairRequestRequest, RepairRequestQueryFilter> {
  final ApiClient _apiClient;

  RepairRequestService({required super.client})
      : _apiClient = client,
        super(
          basePath: '/api/repair-requests',
          fromJson: RepairRequestResponse.fromJson,
        );

  Future<PagedResult<RepairRequestResponse>> getMyRequests(
      RepairRequestQueryFilter filter) async {
    final response = await _apiClient.get(
      '/api/repair-requests/my',
      queryParams: filter.toQueryParameters(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PagedResult.fromJson(json, RepairRequestResponse.fromJson);
  }

  Future<PagedResult<RepairRequestResponse>> getOpenRequests(
      RepairRequestQueryFilter filter) async {
    final response = await _apiClient.get(
      '/api/repair-requests/open',
      queryParams: filter.toQueryParameters(),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PagedResult.fromJson(json, RepairRequestResponse.fromJson);
  }

  Future<RepairRequestResponse> cancel(int id) async {
    final response = await _apiClient.post('/api/repair-requests/$id/cancel');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return RepairRequestResponse.fromJson(json);
  }

  Future<List<RequestImageResponse>> uploadImages(
      int requestId, List<http.MultipartFile> files) async {
    final response = await _apiClient.multipartPost(
      '/api/repair-requests/$requestId/images',
      files: files,
    );
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => RequestImageResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteImage(int requestId, int imageId) async {
    await _apiClient.delete(
      '/api/repair-requests/$requestId/images/$imageId',
    );
  }
}
