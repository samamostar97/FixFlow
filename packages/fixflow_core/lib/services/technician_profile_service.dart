import 'dart:convert';
import 'package:fixflow_core/api/api_client.dart';
import 'package:fixflow_core/models/filters/technician_profile_query_filter.dart';
import 'package:fixflow_core/models/requests/create_technician_profile_request.dart';
import 'package:fixflow_core/models/requests/update_technician_profile_request.dart';
import 'package:fixflow_core/models/responses/technician_profile_response.dart';
import 'package:fixflow_core/services/crud_service.dart';

class TechnicianProfileService extends CrudService<TechnicianProfileResponse,
    CreateTechnicianProfileRequest, UpdateTechnicianProfileRequest, TechnicianProfileQueryFilter> {
  final ApiClient _apiClient;

  TechnicianProfileService({required super.client})
      : _apiClient = client,
        super(
          basePath: '/api/technician-profiles',
          fromJson: TechnicianProfileResponse.fromJson,
        );

  Future<TechnicianProfileResponse> getMyProfile() async {
    final response = await _apiClient.get('/api/technician-profiles/me');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TechnicianProfileResponse.fromJson(json);
  }

  Future<TechnicianProfileResponse> updateMyProfile(
      UpdateTechnicianProfileRequest request) async {
    final response =
        await _apiClient.put('/api/technician-profiles/me', body: request.toJson());
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TechnicianProfileResponse.fromJson(json);
  }

  Future<TechnicianProfileResponse> verify(int id) async {
    final response = await _apiClient.put('/api/technician-profiles/$id/verify');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TechnicianProfileResponse.fromJson(json);
  }
}
